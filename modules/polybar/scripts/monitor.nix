{ pkgs, ...}:

let
  xrandr = "${pkgs.xorg.xrandr}/bin/xrandr";
in
  pkgs.writeShellScriptBin "monitor" ''
    monitors=$(${xrandr} --listmonitors)

    if [[ $monitors == *"HDMI-0"* ]]; then
      echo "HDMI-0"
    elif [[ $monitors == *"HDMI-1"* ]]; then
      echo "HDMI-1"
    elif [[ $monitors == *"DP-0"* ]]; then
      echo "DP-0"
    elif [[ $monitors == *"DP-1"* ]]; then
      echo "DP-1"
    elif [[ $monitors == *"DP-2"* ]]; then
      echo "DP-2"
    elif [[ $monitors == *"DP-3"* ]]; then
      echo "DP-3"
    elif [[ $monitors == *"DP-4"* ]]; then
      echo "DP-4"
    elif [[ $monitors == *"DP-5"* ]]; then
      echo "DP-5"
    else
      echo "HDMI-0"
    fi
  ''
