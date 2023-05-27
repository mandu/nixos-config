{ config, pkgs, ... }:
let
  extra = ''
    ${pkgs.xorg.xset}/bin/xset s off -dpms
    ${pkgs.xorg.setxkbmap}/bin/setxkbmap -option ctrl:nocaps
  '';

  polybarOpts = ''
    ${pkgs.nitrogen}/bin/nitrogen --restore &
    ${pkgs.pasystray}/bin/pasystray &
    ${pkgs.blueman}/bin/blueman-applet &
    ${pkgs.networkmanagerapplet}/bin/nm-applet --sm-disable --indicator &
  '';
in
{
  xresources.properties = {
    # "Xft.dpi" = 180;
    # "Xft.autohint" = 0;
    # "Xft.hintstyle" = "hintfull";
    # "Xft.hinting" = 1;
    # "Xft.antialias" = 1;
    # "Xft.rgba" = "rgb";
    # "Xcursor*theme" = "Vanilla-DMZ-AA";
    "Xcursor*size" = 24;
  };

  xsession = {
    enable = true;
    initExtra = extra + polybarOpts;

    windowManager.xmonad = {
      enable = true;

      extraPackages = hp: [
        hp.xmonad-contrib
        hp.xmonad-extras
        hp.dbus
        hp.monad-logger
      ];
      config = ../../dotfiles/xmonad.hs;
    };
  };
}
