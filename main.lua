tool = renoise.tool()
local config = require "config"
local song = nil
local MAX_LINES = renoise.Pattern.MAX_NUMBER_OF_LINES
local prev_selected_pattern = nil
local pattern_edited = false
local lines_per_beat = 4

local function checkInput()
    pattern_edited = true
end

local function selectPatternNotifier()
    if prev_selected_pattern:has_line_notifier(checkInput) then
        prev_selected_pattern:remove_line_notifier(checkInput)
    end
    if not song.selected_pattern:has_line_notifier(checkInput) then
        song.selected_pattern:add_line_notifier(checkInput)
    end
    prev_selected_pattern = song.selected_pattern
    pattern_edited = false
end

local function calculateNewPatternLength(lines)
    local length_limit = config.prefs.fixed_length_active.value and config.prefs.fixed_length.value or MAX_LINES
    if length_limit < lines then return lines end
    local new_pattern_length = lines + (lines_per_beat * config.prefs.denominator.value)
    return new_pattern_length < length_limit and new_pattern_length or length_limit
end

local function copyPattern()
    return
end

local function checkSongPos()
    local transport = song.transport
    if transport.playing and transport.edit_mode and transport.follow_player then
        if pattern_edited then
            local pos = transport.playback_pos
            local lines = song.selected_pattern.number_of_lines
            if lines - pos.line < 3 then
                song.selected_pattern.number_of_lines = calculateNewPatternLength(lines)
            end
        end
    end
end

local function checkLPB()
    lines_per_beat = song.transport.lpb
end

local function checkEditMode()
    if song.transport.edit_mode and song.transport.follow_player then
        if not tool.app_idle_observable:has_notifier(checkSongPos) then
            tool.app_idle_observable:add_notifier(checkSongPos)
        end
        return
    end
    if tool.app_idle_observable:has_notifier(checkSongPos) then
        tool.app_idle_observable:remove_notifier(checkSongPos)
    end
end

local function main()
    song = renoise.song()
    lines_per_beat = song.transport.lpb
    if not song.transport.lpb_observable:has_notifier(checkLPB) then
        song.transport.lpb_observable:add_notifier(checkLPB)
    end
    if not song.transport.edit_mode_observable:has_notifier(checkEditMode) then
        song.transport.edit_mode_observable:add_notifier(checkEditMode)
    end
    song.selected_pattern:add_line_notifier(checkInput)
    prev_selected_pattern = song.selected_pattern
    song.selected_pattern_observable:add_notifier(selectPatternNotifier)
end

tool.app_new_document_observable:add_notifier(main)

