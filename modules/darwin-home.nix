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

  home.stateVersion = "22.11";
  home.packages = sharedPkgs ++ darwinPkgs;

}
