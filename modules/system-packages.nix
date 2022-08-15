{ config, pkgs, ... }:
let
  myFonts = pkgs.callPackage ./fonts/default.nix { inherit pkgs; };
in
{

  nixpkgs = {
    config.allowUnfree = true;
    config.packageOverrides = pkgs: {
      # override packages here, or add new
    };
  };

  environment.systemPackages = with pkgs; [
    coreutils
    vim
    wget
    git
    curl

    xorg.xmodmap
    lm_sensors
  ];

  # ... and install some fonts.
  fonts = {
    fontDir.enable = true;
    enableDefaultFonts = true;
    enableGhostscriptFonts = true;
    fontconfig.enable = true;

    fonts = with pkgs; [
      powerline-fonts
      corefonts
      dejavu_fonts
      font-awesome
      freefont_ttf
      gohufont
      liberation_ttf
      libertine
      open-sans
      myFonts.flags-world-color
      myFonts.icomoon-feather
    ];
  };

}
