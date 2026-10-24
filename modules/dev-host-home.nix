# Home on an rc dev host (systems/dev-host.nix): the mbp's shell, editor, git
# and command-line tools, without the desktop.
{ config, pkgs, lib, ... }:
let
  sharedPkgs = import ./home-shared-packages.nix {
    inherit config pkgs;
  };
in
{
  imports = [
    ./home-shared.nix
  ];

  home.stateVersion = "26.05";
  home.packages = sharedPkgs ++ (with pkgs; [
    gh # GitHub CLI
  ]);

  # Credentials the hub puts in RAM after boot (`rc hosts secrets`). zshenv,
  # so every zsh has them, the non-interactive ones rc starts sessions with
  # included.
  programs.zsh.envExtra = ''
    if [[ -r /run/user/$UID/rc-secrets/env ]]; then
      set -a; source /run/user/$UID/rc-secrets/env; set +a
    fi
  '';
}
