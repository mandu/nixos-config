{ config, pkgs, ... }:
{
  imports = [
    #./wm/sway.nix          # Wayland
    ./wm/xmonad.nix         # Xorg
  ];

  home.packages = with pkgs; [
    alacritty
    tree
    fd
    ripgrep
    
    firefox
    vscode
    
    gnome3.adwaita-icon-theme
    gnome3.gnome-tweaks
    gnomeExtensions.appindicator
  ];

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
    '';
   

    plugins = with pkgs.vimPlugins; [
      {
        plugin = mini-nvim;
        config = ''
          lua require('mini.base16').mini_palette('#112641', '#e2e98f', 75)
          lua require('mini.comment').setup()
          lua require('mini.completion').setup()
          lua require('mini.cursorword').setup()
          "lua require('mini.indentscope').setup()
          lua require('mini.statusline').setup()
          lua require('mini.trailspace').setup()
        '';
      }
      {
        plugin = telescope-nvim;
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

    ];
  };

  programs.zsh = {
    # zplug = {
    #   enable = true;
    #   plugins = [
    #     { name = "plugins/git"; }
    #     { name = "plugins/python"; }
    #     { name = "plugins/man"; }
    #     { name = "zsh-users/zsh-autosuggestions"; }
    #     { name = "romkatv/powerlevel110k"; tags = [ as:theme depth:1 ]; }
    #   ];
    # };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "python"
        "man"
        #{ name = "" }
      ];
      customPkgs = [ pkgs.nix-zsh-completions ];
      theme = "agnoster";
    };
  };
}
