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
          lua << EOF
            -- Defines a read-write directory for treesitters in nvim's cache dir
            local parser_install_dir = vim.fn.stdpath("cache") .. "/treesitters"
            vim.fn.mkdir(parser_install_dir, "p")

            require'nvim-treesitter.configs'.setup {
              -- A list of parser names, or "all"
              ensure_installed = {
                "c",
                "cpp",
                "cmake",
                "make",
                "python",
                "dockerfile",
                "lua",
                "javascript",
                "typescript",
                "sql",
                "graphql",
                "html",
                "nix",
                "tsx",
                "vim",
                "json",
                "yaml",
                "rust"
                },
            
              -- Install parsers synchronously (only applied to `ensure_installed`)
              sync_install = false,
            
              -- Automatically install missing parsers when entering buffer
              auto_install = true,
            
              -- List of parsers to ignore installing (for "all")
              -- ignore_install = { "javascript" },
            
              highlight = {
                -- `false` will disable the whole extension
                enable = true,
            
                -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
                -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
                -- the name of the parser)
                -- list of language that will be disabled
                -- disable = { "c", "rust" },
            
                -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                -- Using this option may slow down your editor, and you may see some duplicate highlights.
                -- Instead of true it can also be a list of languages
                additional_vim_regex_highlighting = false,
              },

              parser_install_dir = parser_install_dir
            }
          EOF
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
      {
          plugin = gitsigns-nvim;
          config = ''
            lua << EOF
              require('gitsigns').setup {
                signs = {
                  add          = {hl = 'GitSignsAdd'   , text = '+', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
                  change       = {hl = 'GitSignsChange', text = '+', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
                  delete       = {hl = 'GitSignsDelete', text = '_', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
                  topdelete    = {hl = 'GitSignsDelete', text = '‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
                  changedelete = {hl = 'GitSignsChange', text = '~', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
                },
                signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
                numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
                linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
                word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
                watch_gitdir = {
                  interval = 1000,
                  follow_files = true
                },
                attach_to_untracked = true,
                current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
                current_line_blame_opts = {
                  virt_text = true,
                  virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
                  delay = 1000,
                  ignore_whitespace = false,
                },
                current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
                sign_priority = 6,
                update_debounce = 100,
                status_formatter = nil, -- Use default
                max_file_length = 40000, -- Disable if file is longer than this (in lines)
                preview_config = {
                  -- Options passed to nvim_open_win
                  border = 'single',
                  style = 'minimal',
                  relative = 'cursor',
                  row = 0,
                  col = 1
                },
                yadm = {
                  enable = false
                },
                on_attach = function(bufnr)
                  local gs = package.loaded.gitsigns

                  local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                  end

                  -- Navigation
                  map('n', ']c', function()
                    if vim.wo.diff then return ']c' end
                    vim.schedule(function() gs.next_hunk() end)
                    return '<Ignore>'
                  end, {expr=true})

                  map('n', '[c', function()
                    if vim.wo.diff then return '[c' end
                    vim.schedule(function() gs.prev_hunk() end)
                    return '<Ignore>'
                  end, {expr=true})

                  -- Actions
                  map({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>')
                  map({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>')
                  map('n', '<leader>hS', gs.stage_buffer)
                  map('n', '<leader>hu', gs.undo_stage_hunk)
                  map('n', '<leader>hR', gs.reset_buffer)
                  map('n', '<leader>hp', gs.preview_hunk)
                  map('n', '<leader>hb', function() gs.blame_line{full=true} end)
                  map('n', '<leader>tb', gs.toggle_current_line_blame)
                  map('n', '<leader>hd', gs.diffthis)
                  map('n', '<leader>hD', function() gs.diffthis('~') end)
                  map('n', '<leader>td', gs.toggle_deleted)

                  -- Text object
                  map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
               end
              }

            EOF
          '';
      }
      # {
      #   plugin = vim-gitgutter;
      #   config = ''
      #   '';
      # }

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
      {
        plugin = markdown-preview-nvim;
        config = ''
        '';
      }
      {
        plugin = nvim-lspconfig;
        config = ''
          lua << EOF
          -- Use an on_attach function to only map the following keys
          -- after the language server attaches to the current buffer
          local on_attach = function(client, bufnr)
            -- Enable completion triggered by <c-x><c-o>
            vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
          
            -- Mappings.
            -- See `:help vim.lsp.*` for documentation on any of the below functions
            local bufopts = { noremap=true, silent=true, buffer=bufnr }
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
            vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
            vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
            vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
            vim.keymap.set('n', '<space>wl', function()
              print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, bufopts)
            vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
            vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
            vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
            vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
          end
          
          local lsp_flags = {
            -- This is the default in Nvim 0.7+
            debounce_text_changes = 150,
          }
          require('lspconfig')['pyright'].setup{
              on_attach = on_attach,
              flags = lsp_flags,
          }
          require('lspconfig')['tsserver'].setup{
              on_attach = on_attach,
              flags = lsp_flags,
          }

          EOF
        '';
      }
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
      devbox = "kitty +kitten ssh -p 6666 mandu.nsupdate.info";
      icat = "kitty +kitten icat";
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
