{ config, pkgs, ... }:

# let
#   start-sway = pkgs.writeShellScriptBin "start-sway" ''
#     systemctl --user import-environment
#     exec systemctl --user start sway.service
#   '';
# in
{

  ### SWAY ###
  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.displayManager.sddm.enable = false;
  # services.xserver.displayManager.defaultSession = "sway";
  # services.xserver.libinput.enable = true;
  # Configure keymap in X11

  # systemd.user.services.sway = {
  #   description = "Sway - Wayland window manager";
  #   documentation = [ "man:sway(5)" ];
  #   bindsTo = [ "graphical-session.target" ];
  #   wants = [ "graphical-session-pre.target" ];
  #   after = [ "graphical-session-pre.target" ];
  #   serviceConfig = {
  #     ExecStart = "${pkgs.sway}/bin/sway";
  #     Restart = "on-failure";
  #     RestartSec = 1;
  #     TimeoutStopSec = 10;
  #   };
  # };

  programs.sway= {
    enable = true;

    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swaylock
      swayidle
      wl-clipboard
      mako
      dmenu
      kanshi

      qt5.qtwayland
      foot
    ];

    extraOptions = [
      "--unsupported-gpu"
    ];

    # extraSessionCommands = ''
    #   export MOZ_DBUS_REMOTE=1
    #   export MOZ_ENABLE_WAYLAND=1
    #   export QT_QPA_PLATFORM=wayland-egl # needs qt5.qtwayland in systemPackages
    #   export QT_QPA_PLATFORMTHEME="qt5ct"
    #   export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
    #   export __GLX_VENDOR_LIBRARY_NAME=nvidia
    #   export _JAVA_AWT_WM_NONREPARENTING=1
    #   export BEMENU_BACKEND=wayland
    #   export CLUTTER_BACKEND=wayland
    #   export ECORE_EVAS_ENGINE=wayland_egl
    #   export ELM_ACCEL=gl
    #   export ELM_DISPLAY=wl
    #   export ELM_ENGINE=wayland_egl
    #   export GBM_BACKEND=nvidia-drm
    #   # export GBM_BACKENDS_PATH=/etc/gbm
    #   export GDK_BACKEND=wayland
    #   export NO_AT_BRIDGE=1
    #   export SAL_USE_VCLPLUGIN=gtk3
    #   export SDL_VIDEODRIVER=wayland
    #   export WLR_NO_HARDWARE_CURSORS=1
    #   export XDG_CURRENT_DESKTOP="sway"
    #   export XDG_SESSION_TYPE="wayland"
    # '';
  };

    # extraSessionCommands = ''
    #   export SDL_VIDEODRIVER=wayland
    #   export QT_QPA_PLATFORM=wayland
    #   export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
    #   export _JAVA_AWT_WM_NONREPARENTING=1
    #   export MOZ_ENABLE_WAYLAND=1
    # '';
    # # bindsym $mod+Shift+z exec systemctl restart --user kanshi.service
    # extraConfig = ''
    #   exec --no-startup-id systemctl --user import-environment
    #   exec --no-startup-id systemctl --user start sway-session.target
    #   exec --no-startup-id mako &
    # '';
    # config.bars = [{ command = "waybar"; }];

  # programs.waybar.enable = true;


#   systemd.user.services.kanshi = {
#     description = "Kanshi output autoconfig";
#     wantedBy = [ "graphical-session.target" ];
#     partOf = [ "graphical-session.target" ];
#     environment = { XDG_CONFIG_HOME="/home/mandu/.config"; };
#     serviceConfig = {
#       ExecStart = ''
#       ${pkgs.kanshi}/bin/kanshi
#       '';
#       RestartSec = 5;
#       Restart = "always";
#     };
#   };
  ### /SWAY ###

}
