{ config, pkgs, ... }:
let
  defaultPkgs = with pkgs; [
    # aws-sam-cli
    claude-code
    cachix
    coreutils
    curl
    wget
    git
    jpeginfo
    uv

    asciinema            # record the terminal
    awscli2              # Amazon Web Services cli
    # azure-cli            # Azure Cloud cli
    docker-compose       # docker manager
    dive                 # explore docker layers
    #exif                 # read and manipulate EXIF data in digital photographs
    #exiv2                # library and command-line utility to manage image metadata
    fd                   # "find" for files
    file                 # determine file type
    gcc                  # GNU Compiler Collection
    iftop                # Deisplay bandwidth usage on network interface
    #neofetch             # command-line system information
    nb                   # A command line note-taking, bookmarking, archiving, and knowledge base application
    #pulumi-bin           # cloud development platform - infrastructure as a code
    radare2              # unix-like reverse engineering framework and commandline tools
    ranger               # terminal file explorer
    ripgrep              # fast grep
    tree                 # display files in a tree view
    unzip                # list, test and extract compressed files in a ZIP archive
    #wrangler             # cloudflare cli
    zip                  # list, test and extract compressed files in a ZIP archive
    xsel                 # clipboard support (also for neovim)
    #usbutils
    postgresql

    bat
    nmap
    pandoc
    tig
    w3m
    viu

    tree-sitter          # parser generator tool
    jq                   # cli JSON processor
    nodePackages.typescript
    nodePackages.typescript-language-server
    #nodePackages.pyright
    pyright
    nodejs

    diff-so-fancy # git diff with colors
    git-crypt     # git files encryption
    hub           # github command-line client
    tig           # diff and commit view
  ];

  goPkgs = with pkgs; [
    gotools
    gopls
    go-outline
    gopls
    gopkgs
    gocode-gomod
    godef
    golint
  ];
in
[] ++ defaultPkgs ++ goPkgs
