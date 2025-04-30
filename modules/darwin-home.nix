{ config, pkgs, ... }:
let
  sharedPkgs = import ./home-shared-packages.nix {
    inherit config pkgs;
  };

  darwinPkgs = with pkgs; [
  ];

in
{
  imports = [
    ./home-shared.nix
  ];

  home.stateVersion = "24.05";
  home.packages = sharedPkgs ++ darwinPkgs;

  programs.kitty = {
    enable = true;
    themeFile = "SpaceGray";
    extraConfig = ''
      hide_window_decorations titlebar-only
    '';
  };

}
