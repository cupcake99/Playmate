local tool = renoise.tool()
local song = nil
local MAX_LINES = 64 --renoise.Pattern.MAX_NUMBER_OF_LINES
local prev_selected_pattern = nil
local pattern_edited = false
local denominator = 4
local lines_per_beat = 4
local wrap_setting = false

local function checkInput()
    pattern_edited = true
end

local function selectPatternNotifier()
    if prev_selected_pattern:has_line_notifier(checkInput) then
        prev_selected_pattern:remove_line_notifier(checkInput)
    end
    song.selected_pattern:add_line_notifier(checkInput)
    prev_selected_pattern = song.selected_pattern
    pattern_edited = false
end

local function calculateNewPatternLength(lines)
    local new_pattern_length = lines + (lines_per_beat * denominator)
    new_pattern_length = new_pattern_length < MAX_LINES and new_pattern_length or MAX_LINES
    return new_pattern_length
end


local function checkSongPos()
    local transport = song.transport
    if transport.playing and transport.edit_mode and transport.follow_player then
        if pattern_edited then
            transport.wrapped_pattern_edit = false
            local pos = transport.playback_pos
            local lines = song.selected_pattern.number_of_lines
            if lines - pos.line < 3 then
                song.selected_pattern.number_of_lines = calculateNewPatternLength(lines)
            end
            return
        end
    end
    transport.wrapped_pattern_edit = wrap_setting
end

local function main()
    song = renoise.song()
    lines_per_beat = song.transport.lpb
    wrap_setting = song.transport.wrapped_pattern_edit
    song.selected_pattern:add_line_notifier(checkInput)
    prev_selected_pattern = song.selected_pattern
    song.selected_pattern_observable:add_notifier(selectPatternNotifier)
    if not tool.app_idle_observable:has_notifier(checkSongPos) then
        tool.app_idle_observable:add_notifier(checkSongPos)
    end
end

tool.app_new_document_observable:add_notifier(main)

--[[

renoise.song().patterns[]:has_line_notifier(func [, obj])
  -> [boolean]
renoise.song().patterns[]:add_line_notifier(func [, obj])
renoise.song().patterns[]:remove_line_notifier(func [, obj])
renoise.song().patterns[].number_of_lines, _observable

renoise.song().selected_pattern_index, _observable
renoise.song().selected_sequence_index, _observable
--]]






