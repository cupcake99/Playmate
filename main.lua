-- TODO: reset on stop option; key shortcuts; pretty up dialog

tool = renoise.tool()
local config = require "config"
local song = nil
local MAX_LINES = renoise.Pattern.MAX_NUMBER_OF_LINES
local prev_selected_pattern = nil
local prev_pattern_index = nil
local copy_data = {}
local original_pattern_length = nil
local last_copy_start = 1
local last_copy_length = 0
local pattern_edited = false
local lines_per_beat = 4

local function checkInput()
    pattern_edited = true
end

local function selectPatternNotifier()
    copy_data[prev_pattern_index] = {
        start = last_copy_start,
        length = last_copy_length,
        original = original_pattern_length
    }
    if prev_selected_pattern:has_line_notifier(checkInput) then
        prev_selected_pattern:remove_line_notifier(checkInput)
    end
    if not song.selected_pattern:has_line_notifier(checkInput) then
        song.selected_pattern:add_line_notifier(checkInput)
    end
    prev_selected_pattern = song.selected_pattern
    prev_pattern_index = song.selected_pattern_index
    if copy_data[song.selected_pattern_index] then
        original_pattern_length = copy_data[song.selected_pattern_index].original
        last_copy_start = copy_data[song.selected_pattern_index].start
        last_copy_length = copy_data[song.selected_pattern_index].length
    else
        original_pattern_length = song.selected_pattern.number_of_lines
        last_copy_start = 1
        last_copy_length = 0
    end
    pattern_edited = false
end

local function calculateNewPatternLength(lines)
    local length_limit = config.prefs.fixed_length_active.value and config.prefs.fixed_length.value or MAX_LINES
    if length_limit < lines then return lines end
    local new_pattern_length = lines + (lines_per_beat * config.prefs.numerator.value)
    return new_pattern_length < length_limit and new_pattern_length or length_limit
end

local function copyPattern(start, length, offset)
    local pattern = song.selected_pattern_index
    for t=1, #song.tracks do
        if not (t == song.selected_track_index or song.patterns[pattern].tracks[t].is_empty) then
            for i=start, start+length-1 do
                song.patterns[pattern].tracks[t].lines[i+offset]:copy_from(song.patterns[pattern].tracks[t].lines[i])
            end
        end
    end
    last_copy_start = start
    last_copy_length = length
end

local function checkSongPos()
    local transport = song.transport
    local pattern = song.selected_pattern
    if transport.playing and transport.edit_mode and transport.follow_player then
        if pattern_edited then
            local pos = transport.playback_pos
            local lines = pattern.number_of_lines
            if lines - pos.line < 3 then
                pattern.number_of_lines = calculateNewPatternLength(lines)
                if config.prefs.copy_pattern.value then
                    copyPattern(last_copy_start+last_copy_length, pattern.number_of_lines-lines, original_pattern_length)
                end
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
        pattern_edited = false
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
    prev_pattern_index = song.selected_pattern_index
    original_pattern_length = song.selected_pattern.number_of_lines
    song.selected_pattern_observable:add_notifier(selectPatternNotifier)
end

tool.app_new_document_observable:add_notifier(main)

