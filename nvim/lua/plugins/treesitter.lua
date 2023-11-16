return {
  "nvim-treesitter/nvim-treesitter",
  build = "TSUpdate",
  opts = {
    ensure_installed = {
      "bash",
      "lua",
      "markdown",
      "python",
      "ruby",
      "yaml",
    },
  },
}
