-- 基本設定
vim.opt.number = true  -- 行番号を表示
vim.opt.relativenumber = true  -- 相対行番号を表示
vim.opt.wrap = false  -- 長い行を折り返さない
vim.opt.expandtab = true  -- タブをスペースに変換
vim.opt.tabstop = 2  -- タブ幅を2に設定
vim.opt.shiftwidth = 2  -- インデント幅を2に設定
vim.opt.smartindent = true  -- スマートインデントを有効化
vim.opt.ignorecase = true  -- 検索時に大文字小文字を区別しない
vim.opt.smartcase = true  -- 検索パターンに大文字が含まれる場合は大文字小文字を区別
vim.opt.hlsearch = true  -- 検索結果をハイライト
vim.opt.incsearch = true  -- インクリメンタル検索を有効化
vim.opt.termguicolors = true  -- TrueColorを有効化
vim.opt.scrolloff = 8  -- スクロール時に上下8行の視界を確保
vim.opt.sidescrolloff = 8  -- 左右スクロール時に8列の視界を確保
vim.opt.signcolumn = "yes"  -- サインカラムを常に表示
vim.opt.updatetime = 50  -- より高速な更新
vim.opt.colorcolumn = "80"  -- 80列目にラインを表示

-- クリップボード設定
vim.opt.clipboard = "unnamedplus"

-- macOSのクリップボードサポートの確認
if vim.fn.has('mac') == 1 then
  vim.g.clipboard = {
    name = 'macOS-clipboard',
    copy = {
      ['+'] = 'pbcopy',
      ['*'] = 'pbcopy',
    },
    paste = {
      ['+'] = 'pbpaste',
      ['*'] = 'pbpaste',
    },
    cache_enabled = 0,
  }
end

-- オプション: キーマッピング
-- ジュリップボード
vim.api.nvim_set_keymap('n', '<leader>y', '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>y', '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>p', '"+p', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>p', '"+p', { noremap = true, silent = true })
vim.g.mapleader = " "  -- リーダーキーをスペースに設定

-- プラグインマネージャー（packer.nvim）のブートストラップ
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- プラグインの設定
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'  -- パッケージマネージャー
  use 'nvim-treesitter/nvim-treesitter'  -- シンタックスハイライト
  use {
    'nvim-telescope/telescope.nvim',  -- ファジーファインダー
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use 'neovim/nvim-lspconfig'  -- LSP設定
  use 'hrsh7th/nvim-cmp'  -- 自動補完
  use 'hrsh7th/cmp-nvim-lsp'  -- LSPソース for nvim-cmp
  use 'L3MON4D3/LuaSnip'  -- スニペットエンジン
  use 'saadparwaiz1/cmp_luasnip'  -- スニペットソース for nvim-cmp
  use {
    'nvim-lualine/lualine.nvim',  -- ステータスライン
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
  use 'folke/tokyonight.nvim'  -- カラースキーム

  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- カラースキームの設定
vim.cmd[[colorscheme tokyonight]]

-- Treesitter設定
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "lua", "vim", "vimdoc", "javascript", "typescript", "python" },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
  },
}

-- Telescope設定
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- LSP設定
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

lspconfig.tsserver.setup {
  capabilities = capabilities,
}

lspconfig.pyright.setup {
  capabilities = capabilities,
}

-- nvim-cmp設定
local cmp = require'cmp'
local luasnip = require'luasnip'

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
  })
})

-- Lualine設定
require('lualine').setup {
  options = {
    theme = 'tokyonight'
  }
}

-- キーマッピング
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})
