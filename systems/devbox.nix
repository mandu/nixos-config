{ config, pkgs, ... }:

{
  imports =
    [
      ../hardware-configurations/devbox.nix

      ../modules/system-packages.nix
      ../modules/remote-ssh-tunnel.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable cross-compilation using qemu
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "devbox";
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  #networking.networkmanager.enable = true;
  networking.interfaces.enp39s0.useDHCP = true;
  networking.interfaces.wlo1.useDHCP = true;
  # networking.firewall.allowedTCPPortRanges = [ { from = 1714; to = 1764; } ]
  networking.firewall.enable = false;

  # Publish dns to local network
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  services.dbus = {
    enable = true;
    packages = [ pkgs.dconf ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };

  # services.ddclient = {
  #   enable = true;
  #   configFile = "/home/mandu/ddclient_opendns.conf";
  # };

  services.upower.enable = true;
  systemd.services.upower.enable = true;

  programs.zsh = { enable = true; };
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  environment.variables = { EDITOR = "vim"; };
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "lat9w-16";
    #keyMap = "us";
    useXkbConfig = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mandu = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "uinput"]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    initialPassword = "mandu";
  };

  #hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
  # hardware.opengl = {
  #   extraPackages = with pkgs; [ libvdpau-va-gl vaapiVdpau ];
  #   extraPackages32 = with pkgs; [ libvdpau-va-gl vaapiVdpau ];
  # };

  # https://nixos.wiki/wiki/Tensorflow
  # hardware.opengl.setLdLibraryPath = true;

  # environment.variables = {
  #   "GBM_BACKEND" = "nvidia-drm";
  #   "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
  #   "WLR_NO_HARDWARE_CURSORS" = "1";
  #   "GBM_BACKENDS_PATH" = "/run/opengl-driver/lib/gbm";
  #   "OCL_ICD_VENDORS" = "/run/opengl-driver/etc/OpenCL/vendors";
  # };

  services.xserver = {
    enable = true;
    layout = "us";

    libinput.enable = true;

    videoDrivers = [ "nvidia" ];
    desktopManager.xterm.enable = true;

    screenSection = ''
      Monitor        "Monitor0"
      DefaultDepth   24
      Option         "Stereo" "0"
      Option         "nvidiaXineramaInfoOrder" "DFP-2"
      Option         "metamodes" "nvidia-auto-select +0+0 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}"
      Option         "SLI" "Off"
      Option         "MultiGPU" "Off"
      Option         "BaseMosaic" "off"
      SubSection     "Display"
      Depth          24
      EndSubSection
    '';
  };

  services.picom = {
    enable = true;
    settings = {
      "unredir-if-possible" = false;
      "backend" = "xrender";
      "vsync" = true;
    };
  };


  # TODO: If package defines "$out/lib/udev/rules.d" otuput, then the following can be used
  # Until that is in place, manually place the rules for zed cameras
  # services.udev.packages = [ zed ]
  services.udev.extraRules = ''
    # HIDAPI/libusb
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f681", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f781", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f881", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="0666"

    # HIDAPI/hidraw
    KERNEL=="hidraw*", ATTRS{busnum}=="1", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f681", MODE="0666"
    KERNEL=="hidraw*", ATTRS{busnum}=="1", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f781", MODE="0666"
    KERNEL=="hidraw*", ATTRS{busnum}=="1", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f881", MODE="0666"
    KERNEL=="hidraw*", ATTRS{busnum}=="1", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="0666"

    # blacklist for usb autosuspend
    # http://kernel.org/doc/Documentation/usb/power-management.txt
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f780", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f781", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f881", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0424", ATTRS{idProduct}=="2512", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f880", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f582", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f682", TEST=="power/control", ATTR{power/control}="on"

    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f780", TEST=="power/autosuspend", ATTR{power/autosuspend}="-1"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f781", TEST=="power/autosuspend", ATTR{power/autosuspend}="-1"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f881", TEST=="power/autosuspend", ATTR{power/autosuspend}="-1"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0424", ATTRS{idProduct}=="2512", TEST=="power/autosuspend", ATTR{power/autosuspend}="-1"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f880", TEST=="power/autosuspend", ATTR{power/autosuspend}="-1"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f582", TEST=="power/autosuspend", ATTR{power/autosuspend}="-1"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f682", TEST=="power/autosuspend", ATTR{power/autosuspend}="-1"

    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f780", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}="-1"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f781", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}="-1"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f881", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}="-1"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0424", ATTRS{idProduct}=="2512", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}="-1"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f880", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}="-1"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f582", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}="-1"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2b03", ATTRS{idProduct}=="f682", TEST=="power/autosuspend_delay_ms", ATTR{power/autosuspend_delay_ms}="-1"

    # Weylus
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
    '';

  qt.enable = true;
  qt.platformTheme = "gtk2";
  qt.style = "gtk2";

  services.openssh.enable = true;

  # Enable the "SSH reverse tunnel" service for SSH reverse tunneling
  services.remote-ssh-tunnel = {
    enable = true;
    localUser = "mandu";
    remoteHostname = "mandu-droplet.nsupdate.info";
    remotePort = 22;
    remoteUser = "root";
    bindPort = 2222;
  };

  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
  };

  hardware.fancontrol = {
    enable = true;
    config = ''
      INTERVAL=10
      DEVPATH=hwmon1=devices/platform/nct6775.2592 hwmon2=devices/pci0000:00/0000:00:18.3
      DEVNAME=hwmon1=nct6797 hwmon2=k10temp
      FCTEMPS=hwmon1/pwm7=hwmon1/temp1_input hwmon1/pwm6=hwmon2/temp3_input hwmon1/pwm4=hwmon2/temp3_input hwmon1/pwm3=hwmon2/temp3_input hwmon1/pwm5=hwmon2/temp3_input hwmon1/pwm2=hwmon2/temp3_input
      FCFANS=hwmon1/pwm7=hwmon1/fan7_input hwmon1/pwm6=hwmon1/fan6_input hwmon1/pwm4=hwmon1/fan4_input hwmon1/pwm3=hwmon1/fan3_input hwmon1/pwm5=hwmon1/fan5_input hwmon1/pwm2=hwmon1/fan2_input
      MINTEMP=hwmon1/pwm7=40 hwmon1/pwm6=30 hwmon1/pwm4=30 hwmon1/pwm3=30 hwmon1/pwm5=30 hwmon1/pwm2=30
      MAXTEMP=hwmon1/pwm7=70 hwmon1/pwm6=70 hwmon1/pwm4=70 hwmon1/pwm3=70 hwmon1/pwm5=70 hwmon1/pwm2=80
      MINSTART=hwmon1/pwm7=64 hwmon1/pwm6=80 hwmon1/pwm4=80 hwmon1/pwm3=80 hwmon1/pwm5=80 hwmon1/pwm2=80
      MINSTOP=hwmon1/pwm7=34 hwmon1/pwm6=80 hwmon1/pwm4=80 hwmon1/pwm3=80 hwmon1/pwm5=80 hwmon1/pwm2=80
      MAXPWM=hwmon1/pwm7=140 hwmon1/pwm6=220 hwmon1/pwm4=220 hwmon1/pwm3=220 hwmon1/pwm5=200 hwmon1/pwm2=200
    '';
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
