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

  # services.yabai = {
  #   enable = true;
  #   package = pkgs.yabai;
  #   enableScriptingAddition = true;
  #   config = {
  #     focus_follows_mouse          = "autoraise";
  #     mouse_follows_focus          = "off";
  #     window_placement             = "first_child";
  #     window_opacity               = "off";
  #     window_opacity_duration      = "0.0";
  #     window_topmost               = "on";
  #     window_shadow                = "float";
  #     active_window_opacity        = "1.0";
  #     normal_window_opacity        = "1.0";
  #     split_ratio                  = "0.50";
  #     auto_balance                 = "on";
  #     mouse_modifier               = "fn";
  #     mouse_action1                = "move";
  #     mouse_action2                = "resize";
  #     layout                       = "bsp";
  #     top_padding                  = 4;
  #     bottom_padding               = 4;
  #     left_padding                 = 4;
  #     right_padding                = 4;
  #     window_gap                   = 4;
  #   };

  #   extraConfig = ''
  #       # rules
  #       yabai -m rule --add app='System Preferences' manage=off
  #       #yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"

  #       # Any other arbitrary config here
  #     '';
  # };

  services.skhd = {
    enable = true;
    # package = skhd;
    skhdConfig = ''
        # create terminal
        alt - t : kitty

        # focus window
        alt - h : /opt/homebrew/bin/yabai -m window --focus west
        alt - j : /opt/homebrew/bin/yabai -m window --focus south
        alt - k : /opt/homebrew/bin/yabai -m window --focus north
        alt - l : /opt/homebrew/bin/yabai -m window --focus east
        
        # move managed window
        # shift + cmd - h : /opt/homebrew/bin/yabai -m window --warp east
         
        # make floating window fill screen
        alt + shift - up     : /opt/homebrew/bin/yabai -m window --grid 1:1:0:0:1:1
        
        # make floating window fill left-half of screen
        alt + shift - left   : /opt/homebrew/bin/yabai -m window --grid 1:2:0:0:1:1
        
        # fast focus desktop
        # ctrl - x : /opt/homebrew/bin/yabai -m space --focus recent
        # ctrl - 1 : /opt/homebrew/bin/yabai -m space --focus 1
        # ctrl - 2 : /opt/homebrew/bin/yabai -m space --focus 2
        # ctrl - 3 : /opt/homebrew/bin/yabai -m space --focus 3
        # ctrl - 4 : /opt/homebrew/bin/yabai -m space --focus 4
        # ctrl - 5 : /opt/homebrew/bin/yabai -m space --focus 5
        # ctrl - 6 : /opt/homebrew/bin/yabai -m space --focus 6
        # ctrl - 7 : /opt/homebrew/bin/yabai -m space --focus 7
        
        # send window to desktop and follow focus
        # shift + cmd - z : /opt/homebrew/bin/yabai -m window --space next; /opt/homebrew/bin/yabai -m space --focus next
        # shift + cmd - 2 : /opt/homebrew/bin/yabai -m window --space  2; /opt/homebrew/bin/yabai -m space --focus 2

        # swap managed window
        alt + ctrl - h : /opt/homebrew/bin/yabai -m window --swap west
        alt + ctrl - j : /opt/homebrew/bin/yabai -m window --swap south
        alt + ctrl - k : /opt/homebrew/bin/yabai -m window --swap north
        alt + ctrl - l : /opt/homebrew/bin/yabai -m window --swap east
        
        # send window to desktop
        alt + ctrl - 1 : /opt/homebrew/bin/yabai -m window --space  1
        alt + ctrl - 2 : /opt/homebrew/bin/yabai -m window --space  2
        alt + ctrl - 3 : /opt/homebrew/bin/yabai -m window --space  3
        alt + ctrl - 4 : /opt/homebrew/bin/yabai -m window --space  4
        alt + ctrl - 5 : /opt/homebrew/bin/yabai -m window --space  5
        alt + ctrl - 6 : /opt/homebrew/bin/yabai -m window --space  6
        alt + ctrl - 7 : /opt/homebrew/bin/yabai -m window --space  7
        
        # change window size
        alt + shift - 0 : /opt/homebrew/bin/yabai -m space --balance
        alt + shift - h : /opt/homebrew/bin/yabai -m window --resize left:-20:0
        alt + shift - l : /opt/homebrew/bin/yabai -m window --resize left:20:0
        alt + shift - j : /opt/homebrew/bin/yabai -m window --resize top:0:20
        alt + shift - k : /opt/homebrew/bin/yabai -m window --resize top:0:-20
        
        # set insertion point in focused container
        # ctrl + alt - h : /opt/homebrew/bin/yabai -m window --insert west
        
        # toggle window zoom
        alt - d : /opt/homebrew/bin/yabai -m window --toggle zoom-parent
        alt - f : /opt/homebrew/bin/yabai -m window --toggle zoom-fullscreen
        
        # toggle window split type
        alt - space : /opt/homebrew/bin/yabai -m window --toggle split
        
        # float / unfloat window and center on screen
        # alt - t : /opt/homebrew/bin/yabai -m window --toggle float --grid 4:4:1:1:2:2
        
        # toggle sticky(+float), topmost, picture-in-picture
        # alt - p : /opt/homebrew/bin/yabai -m window --toggle sticky --toggle topmost --toggle pip
        # focus monitor
        # ctrl + alt - z  : /opt/homebrew/bin/yabai -m display --focus prev
        # ctrl + alt - 3  : /opt/homebrew/bin/yabai -m display --focus 3
        
        # send window to monitor and follow focus
        # ctrl + cmd - c  : /opt/homebrew/bin/yabai -m window --display next; /opt/homebrew/bin/yabai -m display --focus next
        # ctrl + cmd - 1  : /opt/homebrew/bin/yabai -m window --display 1; /opt/homebrew/bin/yabai -m display --focus 1

        # move floating window
        # shift + ctrl - a : /opt/homebrew/bin/yabai -m window --move rel:-20:0
        # shift + ctrl - s : /opt/homebrew/bin/yabai -m window --move rel:0:20
        
    '';
  };

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
