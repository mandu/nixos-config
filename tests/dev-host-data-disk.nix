# The dev-host data disk (modules/dev-host-data-disk.nix) in VMs, with a disk
# that looks like a Hetzner volume to the guest: a QEMU scsi-hd with vendor
# HC, product Volume, so udev sees ID_SERIAL=0HC_Volume_<serial> (Hetzner's
# volumes show as scsi-0HC_Volume_<id>). Run: nix build .#checks.<system>.dev-host-data-disk
{ pkgs, lib, ... }:

let
  base = {
    virtualisation.docker.enable = true;
    virtualisation.memorySize = 1536;
    # Hetzner's hosts have no KVM: under TCG, more vCPUs, cheap pointer
    # authentication on ARM (QEMU's default is slow to emulate), and time
    # for devices to show up.
    virtualisation.cores = 4;
    boot.kernelParams = [ "systemd.default_device_timeout_sec=900" ];
    # As on Hetzner, where the root disk is virtio-scsi too: a volume is seen
    # from the initrd on, not when udev loads the driver late in the boot.
    boot.initrd.kernelModules = [ "virtio_scsi" ];
    # the bus Hetzner's volumes sit on, before any disk on it
    virtualisation.qemu.options = lib.mkBefore (
      [ "-device virtio-scsi-pci,id=scsi0" ]
      ++ lib.optional pkgs.stdenv.hostPlatform.isAarch64 "-cpu max,pauth-impdef=on"
    );
  };
  # A volume at boot: the image is made by the test before the VM starts,
  # in the VM's state dir (qemu runs there).
  atBoot = serial: [
    "-drive if=none,id=vol,format=raw,file=vol.img"
    "-device scsi-hd,drive=vol,bus=scsi0.0,vendor=HC,product=Volume,serial=${toString serial}"
  ];
in
{
  name = "dev-host-data-disk";

  nodes = {
    # No disk at boot; one is attached while Docker runs.
    plain = {
      imports = [ base ../modules/dev-host-data-disk.nix ];
    };
    # x86-dev's path: running, Docker up, the disk attached before the
    # config that mounts it; then a switch to that config.
    late = {
      imports = [ base ];
      virtualisation.qemu.options = atBoot 4712;
      specialisation.disk.configuration.imports = [ ../modules/dev-host-data-disk.nix ];
    };
    # Booting with the disk.
    booted = {
      imports = [ base ../modules/dev-host-data-disk.nix ];
      virtualisation.qemu.options = atBoot 4713;
    };
  };

  testScript = ''
    import subprocess

    def volume(path):
        path.parent.mkdir(parents=True, exist_ok=True)
        with open(path, "wb") as f:
            f.truncate(256 * 1024 * 1024)
        subprocess.run(["${pkgs.e2fsprogs}/bin/mkfs.ext4", "-q", "-F", str(path)], check=True)

    def diagnose(m):
        for c in [
            "udevadm info --query=property --name=/dev/sda | grep -E 'ID_SERIAL|ID_BUS|DEVLINKS|SYSTEMD|TAGS|DEVTYPE'",
            "ls -l /dev/rc-data /dev/disk/by-id/",
            "systemctl status --no-pager data.mount 'dev-rc\\x2ddata.device' rc-data.service rc-data-dirs.service var-lib-docker.mount",
            "journalctl -b -o short-monotonic --no-pager -u data.mount -u rc-data -u rc-data-dirs -u var-lib-docker.mount -u docker.service | grep -v dockerd | tail -30",
            "systemctl list-jobs --no-pager",
            "journalctl -b --no-pager | grep -iE 'rc-data|rc.x2ddata|data.mount|sda|fsck' | tail -40",
            "cat /etc/udev/rules.d/99-local.rules",
        ]:
            print(c)
            print(m.execute(c)[1])

    def wait_mounted(m, path):
        try:
            m.wait_until_succeeds(f"mountpoint -q {path}", timeout=180)
        except Exception:
            diagnose(m)
            raise

    def docker_pid(m):
        return m.succeed("systemctl show -p MainPID --value docker.service").strip()

    def docker_on_disk(m):
        # Docker's data is the volume's /docker
        try:
            m.succeed("findmnt -no SOURCE /var/lib/docker | grep -q '/dev/sd.\\[/docker\\]'")
        except Exception:
            diagnose(m)
            raise
        m.succeed("docker volume create probe")
        m.succeed("test -d /data/docker/volumes/probe")

    with subtest("no disk: nothing mounted, nothing waits, nothing failed"):
        plain.wait_for_unit("multi-user.target")
        plain.wait_for_unit("docker.service")
        plain.fail("mountpoint -q /data")
        plain.fail("mountpoint -q /var/lib/docker")
        plain.succeed("test \"$(systemctl show -p ActiveState --value data.mount)\" = inactive")
        plain.succeed("test -z \"$(systemctl list-units --failed --plain --no-legend)\"")

    with subtest("attached while Docker runs: /data mounts, Docker is left alone"):
        pid = docker_pid(plain)
        img = plain.state_dir / "hot.img"
        volume(img)
        plain.send_monitor_command(f"drive_add 0 if=none,id=hot,format=raw,file={img}")
        plain.send_monitor_command("device_add scsi-hd,drive=hot,bus=scsi0.0,vendor=HC,product=Volume,serial=4711")
        plain.wait_until_succeeds("test -e /dev/disk/by-id/scsi-0HC_Volume_4711", timeout=180)
        wait_mounted(plain, "/data")
        plain.succeed("test \"$(readlink -f /dev/rc-data)\" = \"$(readlink -f /dev/disk/by-id/scsi-0HC_Volume_4711)\"")
        plain.wait_for_unit("rc-data-dirs.service")
        plain.succeed("test \"$(stat -c %a /data/docker)\" = 710")
        plain.fail("mountpoint -q /var/lib/docker")
        assert docker_pid(plain) == pid, "Docker restarted"

    with subtest("Docker idle: the documented steps move it to the disk"):
        plain.succeed("test -z \"$(docker ps -q)\"")
        plain.succeed("systemctl stop docker.socket docker.service")
        plain.succeed("systemctl start var-lib-docker.mount docker.socket docker.service")
        docker_on_disk(plain)
        plain.shutdown()

    with subtest("disk first, config later (a switch): mounted, Docker left alone"):
        volume(late.state_dir / "vol.img")
        late.wait_for_unit("docker.service")
        late.wait_until_succeeds("test -e /dev/disk/by-id/scsi-0HC_Volume_4712", timeout=300)
        late.fail("test -e /dev/rc-data")
        late.succeed("docker volume create before")
        pid = docker_pid(late)
        out = late.succeed("/run/current-system/specialisation/disk/bin/switch-to-configuration test 2>&1")
        print(out)
        wait_mounted(late, "/data")
        late.wait_for_unit("rc-data-dirs.service")
        late.fail("mountpoint -q /var/lib/docker")
        assert docker_pid(late) == pid, "the switch restarted Docker"
        late.succeed("docker volume inspect before")
        late.succeed("test -z \"$(systemctl list-units --failed --plain --no-legend)\"")
        late.shutdown()

    with subtest("boot with the disk: Docker starts on it"):
        volume(booted.state_dir / "vol.img")
        booted.wait_for_unit("docker.service")
        wait_mounted(booted, "/data")
        docker_on_disk(booted)
        booted.succeed("test -z \"$(systemctl list-units --failed --plain --no-legend)\"")
  '';
}
