local M = {}

M.Show = false

local UI = ui_imgui

local function _Draw(dt)
    if not Clutch.GUI.isWindowVisible('Moderation') then return end
end

M._Draw = _Draw

return M