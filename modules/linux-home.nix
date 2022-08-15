{ config, pkgs, ... }:
let
  sharedPkgs = import ./home-shared-packages.nix {
    inherit config pkgs;
  };

  mainBar = pkgs.callPackage ./polybar/bar.nix {};
  statusBar = import ./polybar/default.nix {
    inherit config pkgs;
    mainBar = mainBar;
    openCalendar = "${pkgs.gnome3.gnome-calendar}/bin/gnome-calendar";
  };

  linuxPkgs = with pkgs; [
    alacritty            # terminal
    firefox              # browser
    chromium

    arandr               # simple GUI for xrandr
    binutils             # Tools for manipulating binaries (linker, assembler, etc.)
    discord              # discord messaging client
    dmenu                # application launcher

    gimp                 # gnu image manipulation program
    killall              # kill processes by name
    libreoffice-fresh    # office suite
    libnotify            # notify-send command
    multilockscreen      # fast lockscreen based on i3lock
    ncdu                 # disk space info (a better du)
    nheko                # matrix messaging client
    openssl              # cryptographic library
    pavucontrol          # pulseaudio volume control
    paprefs              # pulseaudio preferences
    pasystray            # pulseaudio systray
    pulsemixer           # pulseaudio mixer
    signal-desktop       # signal messaging client
    simplescreenrecorder # screen recorder gui
    slack                # messaging client
    tdesktop             # telegram messaging client
    vlc                  # media player
    # weylus               # Use your tablet as graphic tablet/touch screen on your computer
  ];

  gnomePkgs = with pkgs.gnome3; [
    eog            # image viewer
    evince         # pdf reader
    gnome-calendar # calendar
    nautilus       # file manager

    # gnome3.adwaita-icon-theme
    # gnome3.gnome-tweaks
    # gnomeExtensions.appindicator
  ];

  xmonadPkgs = with pkgs; [
    networkmanager_dmenu   # networkmanager on dmenu
    networkmanagerapplet   # networkmanager applet
    nitrogen               # wallpaper manager
    xcape                  # keymaps modifier
    xorg.xkbcomp           # keymaps modifier
    xorg.xmodmap           # keymaps modifier
    xorg.xrandr            # display manager (X Resize and Rotate protocol)
  ];

  scripts = pkgs.callPackage ./scripts/default.nix { inherit config pkgs; };
in
{
  imports = [
    ./home-shared.nix
    ./wm/xmonad.nix         # Xorg
    statusBar
  ];

  home.stateVersion = "22.11";
  home.packages = sharedPkgs ++ linuxPkgs ++ gnomePkgs ++ xmonadPkgs ++ scripts;

  programs.rofi = {
    enable = true;
    terminal = "${pkgs.alacritty}/bin/alacritty";
    theme = ../dotfiles/theme.rafi;
  };

  services.flameshot = {
    enable = true;
  };
}
