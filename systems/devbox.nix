{ config, pkgs, ... }:

{
  imports =
    [
      ../hardware-configurations/devbox.nix

      ../modules/packages.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "devbox";
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;
  networking.interfaces.enp39s0.useDHCP = true;
  networking.interfaces.wlo1.useDHCP = true;

  # Set your time zone.
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
    videoDrivers = [ "nvidia" ];
    desktopManager.xterm.enable = true;
    #displayManager.lightdm.enable = true;

    layout = "us";
    xkbOptions = "eurosign:e";
  };

  qt5.enable = true;
  qt5.platformTheme = "gtk2";
  qt5.style = "gtk2";

  services.openssh.enable = true;
  virtualisation.docker.enable = true;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
