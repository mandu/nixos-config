{ config, pkgs, ... }:

{
  xsession = {
    enable = true;
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      config = ../../dotfiles/xmonad.hs;
    };
  };
}
