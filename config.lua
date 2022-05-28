
local Config = {
    prefs = nil,
    gui = nil
}

Config.prefs = renoise.Document.create {
    fixed_length = 64,
    copy_pattern = false
}
tool.preferences = Config.prefs

-- Config.prefs.input_device:add_notifier(function() print "Input device changed" end)
-- Config.prefs.output_device:add_notifier(function() print "Output device changed" end)

function Config:open_config ()
    local view = renoise.ViewBuilder()
    local DIALOG_MARGIN = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
    local CONTENT_SPACING = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
    local TEXT_ROW_WIDTH = 60
    local MENU_ROW_WIDTH = 80
    local content_view = view:column {
        margin = DIALOG_MARGIN,
        spacing = CONTENT_SPACING,
        view:horizontal_aligner {
            mode = "center",
            spacing = CONTENT_SPACING,
            view:vertical_aligner {
                mode = "distribute",
                spacing = CONTENT_SPACING,
                view:row {
                    style = "plain",
                    view:text {
                        width = TEXT_ROW_WIDTH,
                        align = "center",
                        text = "fixed length"
                    }
                },
                view:row {
                    style = "plain",
                    view:text {
                        width = TEXT_ROW_WIDTH,
                        align = "center",
                        text = "copy pattern"
                    }
                }
            },
            view:vertical_aligner {
                mode = "distribute",
                spacing = CONTENT_SPACING,
                view:row {
                    style = "plain",
                    view:valuebox {
                        -- id = "command",
                        width = MENU_ROW_WIDTH,
                        value = Config.prefs.fixed_length.value,
                        min = 1,
                        max = 512,
                        steps = {[1]=1, [2]=4},
                        notifier = function (value) Config.prefs.fixed_length.value = value end
                    }
                },
                view:row {
                    style = "plain",
                    view:checkbox {
                        value = Config.prefs.copy_pattern.value,
                        notifier = function () Config.prefs.copy_pattern.value = not Config.prefs.copy_pattern.value end
                    }
                }
            }
        },
        -- view:vertical_aligner {
            -- mode = "center",
            -- spacing = CONTENT_SPACING,
            -- view:horizontal_aligner {
                -- mode = "distribute",
                -- spacing = CONTENT_SPACING,
                -- view:row {
                    -- style = "plain",
                    -- view:text {
                        -- width = TEXT_ROW_WIDTH,
                        -- align = "center",
                        -- text = "autostart"
                    -- },
                    -- view:checkbox {
                        -- value = Config.prefs.autostart.value,
                        -- notifier = function () Config.prefs.autostart.value = not Config.prefs.autostart.value end
                    -- }
                -- }
            -- },
            -- view:horizontal_aligner {
                -- mode = "distribute",
                -- spacing = CONTENT_SPACING,
                -- view:row {
                    -- style = "plain",
                    -- view:button {
                        -- text = "restart",
                        -- pressed = function() if push then _push:stop(); _push:start("sysex") end end
                    -- }
                -- }
            -- }
            -- -- add status window, restart button, checkboxes for options etc
        -- }
    }
    self.gui = renoise.app():show_custom_dialog("Playmate Config", content_view)
end

tool:add_menu_entry {
    name = "Main Menu:Tools:Playmate:Open Config",
    invoke = function() Config:open_config() end
}

return Config
