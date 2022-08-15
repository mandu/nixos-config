{ pkgs, lib, ... }:
let
  myFonts = pkgs.callPackage ../modules/fonts/default.nix { inherit pkgs; };
in
{
  imports =
    [
      #../hardware-configurations/devbox.nix

      #../modules/system-packages.nix
    ];

  nixpkgs.config.allowBroken = true;
  nixpkgs.config.allowUnfree = true;

  # nix.binaryCaches = [
  #   "https://cache.nixos.org/"
  # ];
  # nix.binaryCachePublicKeys = [
  #   "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  # ];
  # nix.trustedUsers = [
  #   "@admin"
  # ];
  users = {
    nix.configureBuildUsers = true;
    users = {
      mandu = {
        shell = pkgs.zsh;
        description = "Mikko Haavisto";
        home = "/Users/mandu";
      };
    };
  };

  # Enable experimental nix command and flakes
  # nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
  '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Apps
  # `home-manager` currently has issues adding them to `~/Applications`
  # Issue: https://github.com/nix-community/home-manager/issues/1341
  environment.systemPackages = with pkgs; [
    kitty
    terminal-notifier
  ];

  # https://github.com/nix-community/home-manager/issues/423
  environment.variables = {
    TERMINFO_DIRS = "${pkgs.kitty.terminfo.outPath}/share/terminfo";
    EDITOR = "vim";
  };
  # programs.nix-index.enable = true;

  # Fonts
  # fonts.enableFontDir = true;
  # fonts.fonts = with pkgs; [
  #    recursive
  #    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  #  ];
  fonts = {
    fontDir.enable = true;

    fonts = with pkgs; [
      powerline-fonts
      # corefonts
      recursive
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

  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  # Add ability to used TouchID for sudo authentication
  # security.pam.enableSudoTouchIdAuth = true;

}
