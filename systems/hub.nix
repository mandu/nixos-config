# The rc hub: a small always-on Hetzner Cloud ARM VM (CAX11/CAX21) that
# watches the other rc hosts and keeps copies of their sessions. Installed
# once with nixos-anywhere, then it rebuilds itself every night from this
# flake on GitHub (NixOS stable, newest nixpkgs of that branch).
#
# Everything worth keeping lives on a Hetzner Volume labelled `hub-data`,
# mounted at /data: /home (Claude Code's login and transcripts, rc's
# config and state), Tailscale's identity, secrets. A rebuilt VM with the
# volume reattached is the same hub. Nothing secret is in this file.
{ config, lib, pkgs, modulesPath, ... }:

let
  mbpKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDMw5LeVor//cif07/4WutGDdQPa0j7Wg323fdVCx6bIZGtT5PlYW6Z95eONxF3HR+5hTKrRl1/snvriH7WLdRGM3mEw4OgzgJTCLcHPsqrjJPkMq/jUoiJPgqjFnbvIfLgsNjkJeQ8MBgXCbBfi6sKuDl7XdsY+RAkF7YWPrazwZmrm/yo3tiBWo0jdmovqQugIYGZY2M3RvIHabBBbgH4lffyXFoYxOrpZ9lOF1sQ6r4/5UVwsklkQ7c8Sfv+dF8kXc5Eq7fhmlOkLxE6v3L6PWVzc+agc6I8d/8pdnuyH/ZmFXMROn/IzyZ1W0LaMhGj7cLoL94OMF6Dj8eglXTanc6Msgbj8PUYDXC5gIbne5TYnLvOpHsK8vGvNKsxT0DqpiwgUu4FHb4L0EHm8kuzUDnUoYBSMNRlcCIbNJiqdOicT3vTb2YKW22hYNFmbZUKVUGJTAVFXAu0/hAyFxt+tK1fcMlvsrZFdRHu0lsesdRNomZm/N5mKa9D1+A+Uls= mandu@Mikkos-MacBook-Pro.local";

  # Bind a directory of the data volume over a system path.
  fromData = dir: {
    device = "/data/${dir}";
    fsType = "none";
    options = [ "bind" "nofail" "x-systemd.requires-mounts-for=/data" ];
  };
in
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  networking.hostName = "hub";
  time.timeZone = "Europe/London";
  system.stateVersion = "26.05";

  # Hetzner's ARM VMs boot UEFI; a removable-media install needs no NVRAM.
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # ---- the data volume ------------------------------------------------------
  # Formatted and labelled once by hand (see remote-code docs/hub.md); never
  # in the disko layout, which would format it on a reinstall.
  fileSystems."/data" = {
    device = "/dev/disk/by-label/hub-data";
    fsType = "ext4";
    options = [ "nofail" "x-systemd.device-timeout=60s" ];
  };
  fileSystems."/home" = fromData "home";
  fileSystems."/var/lib/tailscale" = fromData "tailscale";
  # `nofail` keeps a missing volume from blocking boot (OpenSSH stays up for
  # repair), so whatever lives on it must wait for its mount explicitly.
  systemd.services.tailscaled.unitConfig.RequiresMountsFor = [ "/var/lib/tailscale" ];
  systemd.services."user@".unitConfig.RequiresMountsFor = [ "/home" ];

  # ---- you ------------------------------------------------------------------
  users.users.mandu = {
    isNormalUser = true;
    uid = 1000; # the home on the volume is made for this uid before install
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    linger = true; # rc serve's systemd user unit runs without a login
    openssh.authorizedKeys.keys = [ mbpKey ];
  };
  users.users.root.openssh.authorizedKeys.keys = [ mbpKey ];
  # mandu has no password (Tailscale SSH and keys only), so sudo can't ask.
  security.sudo.wheelNeedsPassword = false;
  programs.zsh.enable = true;

  # ---- reaching it ----------------------------------------------------------
  services.tailscale = {
    enable = true;
    # Read on the first start only; Tailscale's state then lives on /data.
    authKeyFile = "/data/secrets/tailscale-authkey";
    extraUpFlags = [ "--ssh" ];
    extraSetFlags = [ "--operator=mandu" ]; # rc runs `tailscale serve`
  };
  # MagicDNS (the hub reaches hosts by name) through systemd-resolved, which
  # keeps Hetzner's DHCP resolvers for everything else. Without it tailscaled
  # took /etc/resolv.conf over with no upstream and nothing outside the
  # tailnet resolved.
  services.resolved.enable = true;
  # Key-only OpenSSH as the way back in if Tailscale breaks. Once Tailscale
  # SSH works, set openFirewall = false to close port 22 publicly.
  services.openssh = {
    enable = true;
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

  # ---- what runs on it ------------------------------------------------------
  # Claude Code's native installer drops a generic Linux binary in ~/.local
  # and keeps it updated itself; nix-ld lets NixOS run it.
  programs.nix-ld.enable = true;
  environment.systemPackages = with pkgs; [
    curl
    git
    htop
    jq
    mosh
    restic
    ripgrep
    tmux
  ];

  # ---- keeping itself current -----------------------------------------------
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "mandu" ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true;

  # Nightly: this flake from GitHub with the newest nixpkgs of the stable
  # branch. A failed build changes nothing; a reboot happens only for a new
  # kernel, inside the window.
  system.autoUpgrade = {
    enable = true;
    flake = "github:mandu/nixos-config#hub";
    flags = [
      "--override-input"
      "nixpkgs-hub"
      "github:NixOS/nixpkgs/nixos-26.05"
      "--print-build-logs"
    ];
    dates = "04:00";
    randomizedDelaySec = "30min";
    allowReboot = true;
    rebootWindow = {
      lower = "04:00";
      upper = "05:30";
    };
  };
}
