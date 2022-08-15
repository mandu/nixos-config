{ config, pkgs, ... }:
let
  defaultPkgs = with pkgs; [
    asciinema            # record the terminal
    awscli2              # Amazon Web Services cli
    azure-cli            # Azure Cloud cli
    binutils             # Tools for manipulating binaries (linker, assembler, etc.)
    docker-compose       # docker manager
    dive                 # explore docker layers
    exif                 # read and manipulate EXIF data in digital photographs
    exiv2                # library and command-line utility to manage image metadata
    fd                   # "find" for files
    file                 # determine file type
    gcc                  # GNU Compiler Collection
    neofetch             # command-line system information
    openssl              # cryptographic library
    pulumi-bin           # cloud development platform - infrastructure as a code
    radare2              # unix-like reverse engineering framework and commandline tools
    ranger               # terminal file explorer
    ripgrep              # fast grep
    tree                 # display files in a tree view
    unzip                # list, test and extract compressed files in a ZIP archive
    wrangler             # cloudflare cli
    zip                  # list, test and extract compressed files in a ZIP archive
    xsel                 # clipboard support (also for neovim)
  ];

  gitPkgs = with pkgs.gitAndTools; [
    diff-so-fancy # git diff with colors
    git-crypt     # git files encryption
    hub           # github command-line client
    tig           # diff and commit view
  ];

  goPkgs = with pkgs; [
    gotools
    gopls
    go-outline
    gocode
    gopkgs
    gocode-gomod
    godef
    golint
  ];
in
[] ++ defaultPkgs ++ gitPkgs ++ goPkgs;