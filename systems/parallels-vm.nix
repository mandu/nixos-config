{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../hardware-configurations/parallels-vm.nix

      ../modules/packages.nix
      #../modules/wm/gnome.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "devbox"; # Define your hostname.
  networking.interfaces.enp0s5.useDHCP = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Helsinki";

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  programs.zsh = { enable = true; };
  environment.variables = { EDITOR = "vim"; };
  i18n.defaultLocale = "en_US.UTF-8";
  console = { font = "lat9w-16"; keyMap = "us"; };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mandu = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    initialPassword = "mandu";
  };

  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = true;
    #displayManager.lightdm.enable = true;

    layout = "us";
    xkbOptions = "eurosign:e";
  };

  services.openssh.enable = true;
  virtualisation.docker.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
