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

  # Homebrew on PATH. home-manager writes ~/.zprofile now, so this moves here
  # from the hand-written one.
  programs.zsh.profileExtra = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';

  programs.kitty = {
    enable = true;
    themeFile = "SpaceGray";
    extraConfig = ''
      hide_window_decorations titlebar-only
      macos_option_as_alt yes
    '';
  };

}
