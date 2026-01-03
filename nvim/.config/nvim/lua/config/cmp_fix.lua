-- Force buffer source to be active after nvim-cmp loads
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyLoad",
  callback = function(event)
    if event.data == "nvim-cmp" then
      vim.schedule(function()
        local ok, cmp = pcall(require, "cmp")
        if not ok then
          return
        end

        -- Check if buffer is in active sources
        local buffer_active = false
        if cmp.core and cmp.core.sources then
          for _, src in ipairs(cmp.core.sources) do
            if src.name == "buffer" then
              buffer_active = true
              break
            end
          end
        end

        if not buffer_active then
          -- Buffer not active, force a full reconfiguration
          local config = cmp.get_config()

          -- Move buffer to group 1
          for _, source in ipairs(config.sources) do
            if source.name == "buffer" then
              source.group_index = 1
            end
          end

          -- Reinitialize cmp with updated config
          cmp.setup(config)
        end
      end)
    end
  end,
})
