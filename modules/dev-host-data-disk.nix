# A dev host's data disk: the Hetzner volume `rc hosts disk <name> --size
# <GB>` makes for it (named after it, ext4, attached). Mounted at /data, with
# Docker's data on it. A host without one runs exactly as before: nothing
# waits for a disk that isn't there.
#
# One config serves every dev host and each volume has its own id, so udev
# names whichever Hetzner volume is attached /dev/rc-data: Hetzner shows a
# volume as /dev/disk/by-id/scsi-0HC_Volume_<id> (udev's ID_SERIAL), the
# root disk as a QEMU_HARDDISK. rc gives a host one volume.
#
# Docker is never touched while it runs: its data moves to the disk when it
# next starts with nothing in the way (a boot), or by hand while no container
# runs:
#   docker ps -q   # empty
#   sudo systemctl stop docker.socket docker.service
#   sudo systemctl start var-lib-docker.mount docker.socket docker.service
{ pkgs, ... }:

{
  # The name, and /data mounted as the volume appears (systemd acts on
  # SYSTEMD_WANTS only when a device first becomes active): attached to a
  # running host, or at boot once udev reaches it.
  services.udev.extraRules = ''
    SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", ENV{ID_SERIAL}=="0HC_Volume_*", SYMLINK+="rc-data", ENV{SYSTEMD_WANTS}+="data.mount"
  '';

  # At boot, and at the switch that brings this config, before Docker
  # starts: wait until udev has seen the boot's devices, name a volume that
  # was attached before this config (udev names a device as it appears), and
  # mount it.
  systemd.services.rc-data = {
    description = "Mount the data disk, if there is one";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-udevd.service" "systemd-udev-trigger.service" ];
    before = [ "docker.service" ];
    path = [ pkgs.systemd ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      udevadm settle --timeout=120 || true
      for v in /dev/disk/by-id/scsi-0HC_Volume_*; do
        [ -e "$v" ] || continue
        [ -e /dev/rc-data ] || udevadm trigger --settle --action=add "$v"
        systemctl start data.mount
        break
      done
    '';
  };

  # Its folders, each time it mounts.
  systemd.services.rc-data-dirs = {
    description = "Folders on the data disk";
    wantedBy = [ "data.mount" ];
    bindsTo = [ "data.mount" ];
    after = [ "data.mount" ];
    unitConfig.DefaultDependencies = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      install -d -m 0710 /data/docker
    '';
  };

  systemd.mounts = [
    # /data: a unit, not an fstab entry. Only the volume pulls it in (the
    # udev rule, rc-data), so a host without one never waits on it. No
    # fsck, as in Hetzner's own fstab line; ext4's journal recovers.
    {
      what = "/dev/rc-data";
      where = "/data";
      type = "ext4";
      options = "nofail,noatime";
    }
    # Docker's data on the disk: /data/docker bound onto /var/lib/docker
    # before Docker starts. Docker's own settings stay as they are, so a
    # switch never restarts it, and a host without a disk keeps its images in
    # place. Never under a running Docker (its pid file): then it waits for
    # the next boot, or the steps at the top.
    {
      what = "/data/docker";
      where = "/var/lib/docker";
      type = "none";
      options = "bind,nofail";
      wantedBy = [ "rc-data-dirs.service" ];
      after = [ "rc-data-dirs.service" ];
      before = [ "docker.service" ];
      unitConfig.ConditionPathExists = "!/run/docker.pid";
    }
  ];
}
