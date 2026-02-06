return {
  {
    "stevearc/conform.nvim",
    opts = {
      default_format_opts = {
        timeout_ms = 3000,
        async = false,
        quiet = false,
        lsp_format = "fallback",
      },
      formatters_by_ft = {
        css = { "prettier" },
        html = { "prettier" },
        htmlangular = { "prettier" },
        javascript = { "prettier" },
        json = { "prettier" },
        lua = { "stylua" },
        sql = { "pg_format" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        -- cs = { "csharpier" },
      },
      format_on_save = function(bufnr)
        local editor = require "utils.editor.core"

        if editor.opts.organize then
          local ft = vim.bo[bufnr].filetype:gsub("react$", "")
          if vim.tbl_contains({ "javascript", "typescript" }, ft) then
            vim.lsp.buf_request_sync(bufnr, "workspace/executeCommand", {
              command = (ft .. ".organizeImports"),
              arguments = { vim.api.nvim_buf_get_name(bufnr) },
            }, 3000)
          end
        end

        if editor.opts.format then
          return { timeout_ms = 500, lsp_fallback = true }
        end
      end,
      formatters = {
        injected = { options = { ignore_errors = true } },
      },
    },
  },
}
