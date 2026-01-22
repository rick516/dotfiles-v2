-- Basic Neovim configuration
vim.opt.number = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2

-- Ensure Packer is installed
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

-- Packer setup
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  -- Add your plugins here
end)

if packer_bootstrap then
  require('packer').sync()
end

local aqua_root = os.getenv('AQUA_ROOT_DIR') or (os.getenv('HOME') .. '/.local/share/aquaproj-aqua')
vim.opt.rtp:append(aqua_root .. '/pkgs/github_release/github.com/junegunn/fzf')
