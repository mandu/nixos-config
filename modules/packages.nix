{ config, pkgs, ... }:
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
  ];

  # ... and install some fonts.
  fonts = {
    fontDir.enable = true;
    enableDefaultFonts = true;
    enableGhostscriptFonts = true;
    fontconfig.enable = true;

    fonts = with pkgs; [
      corefonts
      dejavu_fonts
      envypn-font
      fira-code
      font-awesome
      freefont_ttf
      gohufont
      inconsolata
      iosevka
      liberation_ttf
      libertine
      noto-fonts
      opensans-ttf
      siji
      source-code-pro
      go-font
    ];
  };

}
