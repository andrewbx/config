# Neovim settings.

{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = true;
    
    initLua = ''
      -- Start in Insert Mode automatically
      vim.cmd([[autocmd VimEnter * startinsert]])

      -- Map Ctrl-O to Save
      vim.keymap.set('i', '<C-o>', '<Esc>:w<CR>a')
      vim.keymap.set('n', '<C-o>', ':w<CR>')

      -- Map Ctrl-X to Exit
      vim.keymap.set('i', '<C-x>', '<Esc>:q<CR>')
      vim.keymap.set('n', '<C-x>', ':q<CR>')

      -- Map Ctrl-K to Cut Line
      vim.keymap.set('i', '<C-k>', '<Esc>ddi')
      vim.keymap.set('n', '<C-k>', 'dd')

      -- Map Ctrl-U to Paste
      vim.keymap.set('i', '<C-u>', '<Esc>pi')
      vim.keymap.set('n', '<C-u>', 'p')

      -- Ctrl+W to Search
      vim.keymap.set('i', '<C-w>', '<Esc>/')
      vim.keymap.set('n', '<C-w>', '/')

      -- Enable Mouse
      vim.opt.mouse = 'a'

      vim.g.have_nerd_font = true
      vim.opt.showmode = true
      vim.opt.tabstop = 4
      vim.opt.softtabstop = 4
      vim.opt.shiftwidth = 4
      vim.opt.expandtab = true
      vim.opt.smartindent = true
      vim.opt.wrap = false
      vim.opt.breakindent = true
      vim.opt.swapfile = false
      vim.opt.backup = false
      vim.opt.undofile = true
      vim.opt.hlsearch = false
      vim.opt.incsearch = true
      vim.opt.termguicolors = true
      vim.opt.scrolloff = 8
      vim.opt.signcolumn = 'yes'

      vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>')
      vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<CR>')
      vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>')
      vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<CR>')

      vim.keymap.set('n', '-', '<CMD>Oil<CR>')
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next)

      vim.g.gruvbox_background = "hard"
      vim.cmd.colorscheme('gruvbox')
      vim.api.nvim_set_hl(0, "Normal", { bg = "#0f1118" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#0f1118" })
      
      require('telescope').setup {}
      require('lualine').setup {
        options = {
          theme = 'gruvbox',
        }
      }

      require('gitsigns').setup()
      require('nvim-autopairs').setup()
      require('oil').setup()

      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),

        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }),
      })

      vim.lsp.config('nixd', {})
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim' },
            },
          },
        },
      })

      vim.lsp.enable({
        'nixd',
        'lua_ls',
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local opts = { buffer = args.buf }

          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        end,
      })

      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
    '';

    extraPackages = with pkgs; [
      ripgrep
      fd
      git
      nixd
      alejandra
      lua-language-server
    ];

    # Neovim plugins.
    plugins = with pkgs.vimPlugins; [
      oil-nvim
      telescope-nvim
      plenary-nvim
      (nvim-treesitter.withPlugins (plugins: with plugins; [
        nix
        lua
        vim
        vimdoc
        bash
        zsh
        json
        markdown
        markdown_inline
      ]))
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      luasnip
      gitsigns-nvim
      lualine-nvim
      comment-nvim
      nvim-autopairs
      editorconfig-vim
      gruvbox
      tabular
      vim-elixir
      vim-nix
      vim-markdown
    ];
  };
}
