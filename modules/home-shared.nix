{ config, pkgs, ... }:
let
  foobar = "baz";
in
{
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
}
