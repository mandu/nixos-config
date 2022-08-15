{ config, pkgs, ... }:
let
  mainBar = pkgs.callPackage ./polybar/bar.nix {};
  statusBar = import ./polybar/default.nix {
    inherit config pkgs;
    mainBar = mainBar;
    openCalendar = "${pkgs.gnome3.gnome-calendar}/bin/gnome-calendar";
  };

  defaultPkgs = with pkgs; [
    alacritty            # terminal
    firefox              # browser
    chromium
    vscode               # code editor

    arandr               # simple GUI for xrandr
    asciinema            # record the terminal
    awscli2              # Amazon Web Services cli
    azure-cli            # Azure Cloud cli
    binutils             # Tools for manipulating binaries (linker, assembler, etc.)
    discord              # discord messaging client
    dmenu                # application launcher
    docker-compose       # docker manager
    dive                 # explore docker layers
    exif                 # read and manipulate EXIF data in digital photographs
    exiv2                # library and command-line utility to manage image metadata
    fd                   # "find" for files
    file                 # determine file type
    gcc                  # GNU Compiler Collection
    gimp                 # gnu image manipulation program
    killall              # kill processes by name
    libreoffice-fresh    # office suite
    libnotify            # notify-send command
    multilockscreen      # fast lockscreen based on i3lock
    ncdu                 # disk space info (a better du)
    neofetch             # command-line system information
    nheko                # matrix messaging client
    openssl              # cryptographic library
    pavucontrol          # pulseaudio volume control
    paprefs              # pulseaudio preferences
    pasystray            # pulseaudio systray
    pulsemixer           # pulseaudio mixer
    pulumi-bin           # cloud development platform - infrastructure as a code
    radare2              # unix-like reverse engineering framework and commandline tools
    ranger               # terminal file explorer
    ripgrep              # fast grep
    signal-desktop       # signal messaging client
    simplescreenrecorder # screen recorder gui
    slack                # messaging client
    tdesktop             # telegram messaging client
    tree                 # display files in a tree view
    unzip                # list, test and extract compressed files in a ZIP archive
    vlc                  # media player
    wrangler             # cloudflare cli
    # weylus               # Use your tablet as graphic tablet/touch screen on your computer
    zip                  # list, test and extract compressed files in a ZIP archive
    xsel                 # clipboard support (also for neovim)
  ];

  gitPkgs = with pkgs.gitAndTools; [
    diff-so-fancy # git diff with colors
    git-crypt     # git files encryption
    hub           # github command-line client
    tig           # diff and commit view
  ];


  gnomePkgs = with pkgs.gnome3; [
    eog            # image viewer
    evince         # pdf reader
    gnome-calendar # calendar
    nautilus       # file manager

    # gnome3.adwaita-icon-theme
    # gnome3.gnome-tweaks
    # gnomeExtensions.appindicator
  ];

  xmonadPkgs = with pkgs; [
    networkmanager_dmenu   # networkmanager on dmenu
    networkmanagerapplet   # networkmanager applet
    nitrogen               # wallpaper manager
    xcape                  # keymaps modifier
    xorg.xkbcomp           # keymaps modifier
    xorg.xmodmap           # keymaps modifier
    xorg.xrandr            # display manager (X Resize and Rotate protocol)
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

  scripts = pkgs.callPackage ./scripts/default.nix { inherit config pkgs; };
in
{
  imports = [
    ./wm/xmonad.nix         # Xorg
    statusBar
  ];

  home.stateVersion = "22.11";
  home.packages = defaultPkgs ++ gitPkgs ++ gnomePkgs ++ xmonadPkgs ++ goPkgs ++ scripts;

  programs.ssh.enable = true;

  programs.htop = {
    enable = true;
    settings = {
      sort_key = "46";
      sort_direction = 0;
    };
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    withPython3 = true;

    extraConfig = ''
      set nocompatible
      set nobackup
      set number
      let mapleader=","
      set backspace=indent,eol,start
    '';


    plugins = with pkgs.vimPlugins; [
      { plugin = telescope-nvim;
        config = ''
          lua << EOF
          require('telescope').setup({
            extensions = {
              fzf = {
                fuzzy = true,
                override_generic_sorter = true,
                override_file_sorter = true,
                case_mode = "smart_case",

              }
            }
          })
          EOF
          lua require('telescope').load_extension('fzf')

          let mapleader=","
          nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
          nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
          nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
          nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>
        '';
      }
      {
        plugin = vim-fugitive;
        config = ''
        '';
      }
      {
        plugin = vim-airline;
        config = ''
        '';
      }
      {
        plugin = vim-airline-themes;
        config = ''
        '';
      }
      {
        plugin = deoplete-nvim;
        config = ''
          let g:deoplete#enable_at_startup = 1
        '';
      }
      {
        plugin = vim-polyglot;
        config = ''
        '';
      }
      {
        plugin = nvim-treesitter;
        config = ''
        '';
      }
      {
        plugin = telescope-fzf-native-nvim;
        config = ''
        '';
      }
      {
        plugin = vim-unimpaired;
        config = ''
        '';
      }
      {
        plugin = ultisnips;
        config = ''
        '';
      }
      {
        plugin = vim-go;
        config = ''
          let mapleader=","

          autocmd Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
          autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
          autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')

          autocmd FileType go nmap <leader>r  <Plug>(go-run)
          autocmd FileType go nmap <leader>t  <Plug>(go-test)
          autocmd FileType go nmap <leader>tf  <Plug>(go-test-func)
          autocmd FileType go nmap <Leader>c <Plug>(go-coverage-toggle)
          autocmd FileType go nmap <Leader>d <Plug>(go-doc)

          autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4

          "autocmd FileType go nmap <Leader>i <Plug>(go-info)
          " let g:go_auto_type_info = 1
          " set updatetime=100

          " autocmd FileType go nmap <leader>b  <Plug>(go-build)
          " run :GoBuild or :GoTestCompile based on the go file
          function! s:build_go_files()
            let l:file = expand('%')
            if l:file =~# '^\f\+_test\.go$'
              call go#test#Test(0, 1)
            elseif l:file =~# '^\f\+\.go$'
              call go#cmd#Build(0)
            endif
          endfunction
          autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>


          " Automatic imports
          " let g:go_fmt_command = "goimports"
          " Prefer quickfix only instead of both quickfix and location
          let g:go_list_type = "quickfix"

          let g:go_highlight_types = 1
          let g:go_highlight_fields = 1
          let g:go_highlight_functions = 1
          let g:go_highlight_function_calls = 1
          let g:go_highlight_operators = 1
          let g:go_highlight_extra_types = 1

          let g:go_metalinter_enabled = ['vet', 'golint', 'errcheck']

          " These are already installed when using nix
          let g:go_disable_autoinstall = 1

          "let g:go_auto_sameids = 1

        '';
      }
      {
        plugin = deoplete-go;
        config = ''
          let g:go_def_mode = "gopls"
          call deoplete#custom#option('omni_patterns', {
          \ 'go': '[^. *\t]\.\w*',
          \})
        '';
      }
      # {
      #   plugin = deoplete-clang;
      #   config = ''
      #   '';
      # }
      # {
      #   plugin = deoplete-jedi;
      #   config = ''
      #   '';
      # }
    ];
  };

  programs.go = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    localVariables = {
      POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD = true;
    };

    shellAliases = {
      update = "sudo -u mandu nixos-rebuild switch";
    };

    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-syntax-highlighting"; }
        { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; }
      ];
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "man"
        "colored-man-pages"
      ];
    };
  };

  programs.command-not-found.enable = true;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.rofi = {
    enable = true;
    terminal = "${pkgs.alacritty}/bin/alacritty";
    theme = ../dotfiles/theme.rafi;
  };

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    prefix = "C-b";
    customPaneNavigationAndResize = true;
  };

  programs.git = {
    enable = true;
    userName = "Mikko Haavisto";
    userEmail = "mvi.haavisto@gmail.com";
    aliases = {
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
    };
  };

  services.flameshot = {
    enable = true;
  };

}
