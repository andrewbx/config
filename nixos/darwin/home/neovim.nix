# Neovim settings.

{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;
    
    extraConfig = ''
      :imap jk <Esc>
      :set number
    '';

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
      vim.opt.breakindent = true
      vim.opt.tabstop = 4
      vim.opt.softtabstop = 4
      vim.opt.shiftwidth = 4
      vim.opt.expandtab = true
      vim.opt.smartindent = true
      vim.opt.wrap = false
      vim.opt.incsearch = true
      vim.opt.swapfile = false
    '';
      
    # Neovim plugins.
    plugins = with pkgs.vimPlugins; [
      ctrlp-vim
      editorconfig-vim
      gruvbox
      nerdtree
      tabular
      vim-elixir
      vim-nix
      vim-markdown
    ];
  };
}
