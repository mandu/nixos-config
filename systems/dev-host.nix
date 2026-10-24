# A disposable rc dev host: a Hetzner Cloud VM that `rc hosts up` creates and
# installs with nixos-anywhere, and `rc hosts down` deletes. Nothing on it is
# meant to last: the hub copies its sessions every 5 min, and credentials
# arrive from the hub into RAM (/run/user/1000/rc-secrets) after boot. One
# config serves every dev host on either CPU (outputs dev-x86, dev-arm); each
# host's name comes from Hetzner's metadata service. Nothing secret is in
# this file.
{ config, lib, pkgs, modulesPath, ... }:

let
  mbpKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDMw5LeVor//cif07/4WutGDdQPa0j7Wg323fdVCx6bIZGtT5PlYW6Z95eONxF3HR+5hTKrRl1/snvriH7WLdRGM3mEw4OgzgJTCLcHPsqrjJPkMq/jUoiJPgqjFnbvIfLgsNjkJeQ8MBgXCbBfi6sKuDl7XdsY+RAkF7YWPrazwZmrm/yo3tiBWo0jdmovqQugIYGZY2M3RvIHabBBbgH4lffyXFoYxOrpZ9lOF1sQ6r4/5UVwsklkQ7c8Sfv+dF8kXc5Eq7fhmlOkLxE6v3L6PWVzc+agc6I8d/8pdnuyH/ZmFXMROn/IzyZ1W0LaMhGj7cLoL94OMF6Dj8eglXTanc6Msgbj8PUYDXC5gIbne5TYnLvOpHsK8vGvNKsxT0DqpiwgUu4FHb4L0EHm8kuzUDnUoYBSMNRlcCIbNJiqdOicT3vTb2YKW22hYNFmbZUKVUGJTAVFXAu0/hAyFxt+tK1fcMlvsrZFdRHu0lsesdRNomZm/N5mKa9D1+A+Uls= mandu@Mikkos-MacBook-Pro.local";
  # The hub installs dev hosts and can still reach them over their public
  # address (the Hetzner firewall lets only the hub's in) if Tailscale fails.
  hubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMcvsUN7UhKMO8Zi9Ie6jaUCosYyltu4+F4d/2rcq855 mandu@hub (rc: installs dev hosts)";
in
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  system.stateVersion = "26.05";
  time.timeZone = "Europe/London";
  nixpkgs.config.allowUnfree = true; # as on the Macs (vim-polyglot, …)

  # ARM VMs boot UEFI, x86 ones BIOS: grub covers both (see the disk below).
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/sda";
    content = {
      type = "gpt";
      partitions = {
        # grub's BIOS boot partition: used on x86, harmless on ARM
        boot = {
          size = "1M";
          type = "EF02";
        };
        ESP = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };

  # ---- its name -------------------------------------------------------------
  # The server's name in Hetzner (e.g. cloud1), set before Tailscale logs in
  # so the tailnet knows the host by it too.
  networking.hostName = "";
  systemd.services.hetzner-hostname = {
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    before = [ "tailscaled.service" "tailscaled-autoconnect.service" ];
    path = [ pkgs.curl ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      for i in $(seq 30); do
        name=$(curl -fsS -m 5 http://169.254.169.254/hetzner/v1/metadata/hostname) && break
        sleep 2
      done
      if [ -n "''${name:-}" ]; then hostnamectl set-hostname "$name"; fi
    '';
  };

  # ---- you ------------------------------------------------------------------
  users.users.mandu = {
    isNormalUser = true;
    uid = 1000;
    # The mbp's home path, so Claude files conversations under the same
    # project folders (-Users-mandu-dev-…) here and there, and a session can
    # move between them without rewriting its transcript.
    home = "/Users/mandu";
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
    linger = true; # rc serve's systemd user unit runs without a login
    openssh.authorizedKeys.keys = [ mbpKey hubKey ];
  };
  users.users.root.openssh.authorizedKeys.keys = [ mbpKey hubKey ];
  security.sudo.wheelNeedsPassword = false;
  programs.zsh.enable = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.mandu = import ../modules/dev-host-home.nix;

  # ---- reaching it ----------------------------------------------------------
  services.tailscale = {
    enable = true;
    # A one-off key tagged tag:dev that `rc hosts up` hands the installer
    # (nixos-anywhere --extra-files); read on the first start only.
    authKeyFile = "/var/lib/rc-bootstrap/tailscale-authkey";
    extraUpFlags = [ "--ssh" ];
    extraSetFlags = [ "--operator=mandu" ]; # rc runs `tailscale serve`
  };
  services.resolved.enable = true; # MagicDNS beside Hetzner's resolvers
  # Key-only OpenSSH. Port 22 is open here, but the Hetzner Cloud firewall
  # `rc hosts up` attaches admits only the hub's address.
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ]; # rc serve, mosh: tailnet only
    allowedUDPPorts = [ config.services.tailscale.port ];
  };
  # GitHub's published host keys, so the first clone needs no trust-on-first-use.
  programs.ssh.knownHosts = {
    "github.com-ed25519" = {
      hostNames = [ "github.com" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };
    "github.com-ecdsa" = {
      hostNames = [ "github.com" ];
      publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=";
    };
  };

  # ---- what runs on it ------------------------------------------------------
  # Claude Code's native installer puts a generic Linux binary in ~/.local
  # that updates itself; nix-ld lets NixOS run it.
  programs.nix-ld.enable = true;
  environment.localBinInPath = true;
  environment.systemPackages = with pkgs; [
    curl
    git
    htop
    jq
    mosh
    ripgrep
    tmux
  ];
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "mandu" ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
}
