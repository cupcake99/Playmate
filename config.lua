
local Config = {
    prefs = nil,
    gui = nil
}

Config.prefs = renoise.Document.create {
    fixed_length = 64,
    fixed_length_active = false,
    copy_pattern = false,
    denominator = 4
}
tool.preferences = Config.prefs

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
                        text = "fixed lines"
                    }
                },
                view:row {
                    style = "plain",
                    view:text {
                        width = TEXT_ROW_WIDTH,
                        align = "center",
                        text = "beats per bar"
                    }
                },
                -- view:row {
                    -- style = "plain",
                    -- view:text {
                        -- width = TEXT_ROW_WIDTH,
                        -- align = "center",
                        -- text = "copy pattern"
                    -- }
                -- }
            },
            view:vertical_aligner {
                mode = "distribute",
                spacing = CONTENT_SPACING,
                view:row {
                    style = "plain",
                    view:checkbox {
                        value = Config.prefs.fixed_length_active.value,
                        notifier = function ()
                            Config.prefs.fixed_length_active.value = not Config.prefs.fixed_length_active.value
                        end
                    }
                },
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
                    view:valuebox {
                        -- id = "command",
                        width = MENU_ROW_WIDTH,
                        value = Config.prefs.denominator.value,
                        min = 1,
                        max = 32,
                        steps = {[1]=1, [2]=2},
                        notifier = function (value) Config.prefs.denominator.value = value end
                    }
                },
                -- view:row {
                    -- style = "plain",
                    -- view:checkbox {
                        -- value = Config.prefs.copy_pattern.value,
                        -- notifier = function () Config.prefs.copy_pattern.value = not Config.prefs.copy_pattern.value end
                    -- }
                -- }
            }
        }
    }
    self.gui = renoise.app():show_custom_dialog("Playmate Config", content_view)
end

tool:add_menu_entry {
    name = "Main Menu:Tools:Playmate:Open Config",
    invoke = function() Config:open_config() end
}

return Config

