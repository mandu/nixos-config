{ config, pkgs, lib, ... }:
let
  foobar = "baz";
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    # Host blocks, with OpenSSH's own directive names.
    settings = {
      "devbox" = {
        ProxyCommand = "ssh -q root@mandu-droplet.nsupdate.info nc localhost 2222";
        User = "mandu";
        IdentityFile = "~/.ssh/id_rsa";
      };
      # RRGPU test bench Jetson (Orin NX dev kit), over Tailscale. Plain
      # "rrgpu" resolves to another host on the LAN, so pin the address.
      "rrgpu rrgpu-bench" = {
        HostName = "100.64.136.44";
        User = "rrgpu";
      };
    };
  };

  # The RRGPU device lane (./rrtest replay) runs against this ssh destination.
  home.sessionVariables.RRTEST_JETSON = "rrgpu@rrgpu-bench";

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
    withRuby = true;

    extraConfig = ''
      set nocompatible
      set nobackup
      set number
      let mapleader=","
      set backspace=indent,eol,start
    '';

    plugins = with pkgs.vimPlugins; [
      { plugin = telescope-nvim;
        type = "viml";
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
      # {
      #   plugin = deoplete-nvim;
      #   config = ''
      #     let g:deoplete#enable_at_startup = 1
      #   '';
      # }
      {
        plugin = vim-polyglot;
        config = ''
        '';
      }
      {
        plugin = nvim-treesitter.withAllGrammars;
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
        type = "viml";
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
      # {
      #   plugin = deoplete-go;
      #   config = ''
      #     let g:go_def_mode = "gopls"
      #     call deoplete#custom#option('omni_patterns', {
      #     \ 'go': '[^. *\t]\.\w*',
      #     \})
      #   '';
      # }
      {
          plugin = gitsigns-nvim;
          type = "viml";
          config = ''
            lua << EOF
              require('gitsigns').setup {

              signs = {
                add          = { text = '┃' },
                change       = { text = '┃' },
                delete       = { text = '_' },
                topdelete    = { text = '‾' },
                changedelete = { text = '~' },
                untracked    = { text = '┆' },
              },
              signs_staged = {
                add          = { text = '┃' },
                change       = { text = '┃' },
                delete       = { text = '_' },
                topdelete    = { text = '‾' },
                changedelete = { text = '~' },
                untracked    = { text = '┆' },
              },
              signs_staged_enable = true,
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
        type = "viml";
        config = ''
          lua << EOF
          -- Mappings.
          -- See `:help vim.diagnostic.*` for documentation on any of the below functions
          local opts = { noremap=true, silent=true }
          vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
          vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

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
            vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
          end

          -- Configure LSP servers using the new vim.lsp.config API (Neovim 0.11+)
          vim.lsp.config['pyright'] = {
            on_attach = on_attach,
          }
          vim.lsp.config['ts_ls'] = {
            on_attach = on_attach,
          }

          -- Enable the configured LSP servers
          vim.lsp.enable('pyright')
          vim.lsp.enable('ts_ls')

          EOF
        '';
      }
      {
        plugin = nui-nvim;
      }
      {
        plugin = plenary-nvim;
      }
      {
        plugin = snacks-nvim;
        type = "viml";
        config = ''
          lua << EOF
          require('snacks').setup({})
          EOF
        '';
      }
      {
        plugin = claudecode-nvim;
        type = "viml";
        config = ''
          lua << EOF
          require('claudecode').setup({
            terminal = {
              split_side = "right",
              split_width_percentage = 0.40,
            },
          })
          -- Keybindings
          vim.keymap.set('n', '<leader>cc', '<cmd>ClaudeCode<cr>', { desc = 'Toggle Claude Code' })
          vim.keymap.set('n', '<leader>cf', '<cmd>ClaudeCodeFocus<cr>', { desc = 'Focus Claude Code' })
          vim.keymap.set('v', '<leader>cs', '<cmd>ClaudeCodeSend<cr>', { desc = 'Send to Claude' })
          EOF
        '';
      }
      {
        plugin = minuet-ai-nvim;
        type = "viml";
        config = ''
          lua << EOF
          require('minuet').setup({
            provider = 'gemini',
            provider_options = {
              gemini = {
                model = 'gemini-2.5-flash-lite',
                api_key = 'GEMINI_API_KEY',
              },
            },
            virtualtext = {
              auto_trigger_ft = { '*' },
              keymap = {
                accept = '<C-y>',
                accept_line = '<C-j>',
                prev = '<C-p>',
                next = '<C-n>',
                dismiss = '<C-e>',
              },
            },
          })
          EOF
        '';
      }
      {
        plugin = ChatGPT-nvim;
        type = "viml";
        config = ''
          lua << EOF
          require('chatgpt').setup({})
          openai_params = {
            model = "gpt-3.5-turbo"
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
    autosuggestion = {
      enable = true;
    };
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      update = "sudo -u mandu nixos-rebuild switch";
      devbox = "kitty +kitten ssh -p 6666 mandu.nsupdate.info";
      icat = "kitty +kitten icat";
      claude-rr = "CLAUDE_CONFIG_DIR=$HOME/.claude-rr claude";
    };

    initContent = ''
      # Load secrets from local files (not tracked in git)
      [[ -f ~/.config/secrets/openai ]] && export OPENAI_API_KEY=$(cat ~/.config/secrets/openai)
      [[ -f ~/.config/secrets/gemini ]] && export GEMINI_API_KEY=$(cat ~/.config/secrets/gemini)
      [[ -f ~/.config/secrets/jira ]] && export JIRA_API_TOKEN=$(cat ~/.config/secrets/jira)
      [[ -f ~/.config/secrets/zai ]] && export ZAI_API_KEY=$(cat ~/.config/secrets/zai)
    '';

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

  # Prompt. Plain 7-bit ASCII only (no Nerd Font/Powerline glyphs, no emoji),
  # so it renders the same in any font, terminal and locale, ssh clients
  # included. Two lines: everything informative on the first, the input on
  # its own line so long paths never wrap the command line. No right prompt
  # (it garbles scrollback when an ssh window is resized).
  #
  #   21:04 mandu@Mikkos-MacBook-Pro nixos-config/modules on main [+1!2?3>1] via nix took 12s exit 1
  #   $
  #
  # user@host only over ssh (or as another user/root). Git status mostly follows
  # git-prompt.sh: + staged, ! modified, ? untracked, x deleted, r renamed,
  # = conflicted, $ stashed, >N ahead, <N behind.
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = lib.concatStrings [
        "$time"
        "($username$hostname )"
        "$directory"
        "$git_branch"
        "$git_commit"
        "$git_state"
        "$git_status"
        "$nix_shell"
        "$python"
        "$cmd_duration"
        "$jobs"
        "$status"
        "$line_break"
        "$character"
      ];

      time = {
        disabled = false;
        time_format = "%H:%M";
        format = "[$time]($style) ";
        style = "bright-black";
      };
      username = {
        format = "[$user]($style)";
        style_user = "bold yellow";
        style_root = "bold red";
      };
      hostname = {
        ssh_only = true;
        format = "[@$hostname]($style)";
        style = "bold yellow";
      };
      # Inside a repo, the path from the repo root.
      directory = {
        truncation_length = 4;
        read_only = " (ro)";
      };
      git_branch = {
        format = "on [$branch(:$remote_branch)]($style) ";
        only_attached = true;
        truncation_length = 40;
        truncation_symbol = "...";
      };
      # Detached HEAD: on @c4d3ec2.
      git_commit = {
        format = "on [@$hash]($style) ";
      };
      git_status = {
        conflicted = "=\${count}";
        ahead = ">\${count}";
        behind = "<\${count}";
        diverged = ">\${ahead_count}<\${behind_count}";
        untracked = "?\${count}";
        stashed = "\\$\${count}";
        modified = "!\${count}";
        staged = "+\${count}";
        renamed = "r\${count}";
        deleted = "x\${count}";
        typechanged = "t\${count}";
      };
      # nix develop, nix-shell, and direnv's use flake.
      nix_shell = {
        format = "via [nix( $state)( \\($name\\))]($style) ";
        impure_msg = "";
        pure_msg = "pure";
        unknown_msg = "";
      };
      # Only an activated virtualenv, not every directory with Python files.
      python = {
        format = "via [venv \\($virtualenv\\)]($style) ";
        detect_extensions = [ ];
        detect_files = [ ];
        detect_folders = [ ];
      };
      cmd_duration = {
        format = "took [$duration]($style) ";
      };
      jobs = {
        format = "[jobs:$number]($style) ";
        number_threshold = 1;
      };
      status = {
        disabled = false;
        format = "[exit $status( \\(SIG$signal_name\\))]($style) ";
      };
      character = {
        success_symbol = "[\\$](bold green)";
        error_symbol = "[\\$](bold red)";
      };
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
    extraConfig = ''
      # Status bar with rr slot info
      set -g status-right '#[fg=cyan]#(cat ~/.rr-active-slot 2>/dev/null || echo "-") #[default]| %H:%M'

      # Pane titles
      set -g pane-border-status top
      set -g pane-border-format " #{pane_title} "

      # Mouse support
      set -g mouse on

      # Better colors
      set -g default-terminal "screen-256color"

      # Shell defaults
      set -gu default-command
      set -g default-shell "$SHELL"
    '';
  };

  # Add rr-workspace CLI, ~/.local/bin, and vite+ to PATH
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/dev/rr-workspace/rr-workspace/bin"
    "$HOME/.vite-plus/bin"
  ];

  programs.git = {
    enable = true;
    signing.format = "openpgp";
    settings = {
      user = {
        name = "Mikko Haavisto";
        email = "mvi.haavisto@gmail.com";
      };
      alias = {
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      };
    };
  };

  # Neovim plugin configs in after/plugin/ to ensure plugins are loaded first
  xdg.configFile."nvim/after/plugin/treesitter.lua".text = ''
    local ok, configs = pcall(require, "nvim-treesitter.configs")
    if not ok then
      return
    end

    configs.setup({
      highlight = {
        enable = true,
        disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok_stat, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok_stat and stats and stats.size > max_filesize then
            return true
          end
        end,
        additional_vim_regex_highlighting = false,
      },
    })
  '';
}
