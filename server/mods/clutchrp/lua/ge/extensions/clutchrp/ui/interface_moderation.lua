local M = {}

local imgui = ui_imgui

M.shouldDraw = true
M.shouldDrawCommand = false

local viewport = imgui.GetMainViewport()
local windowSize = {
    x = 700,
    y = 500
}

local windowStyles = bit.bor(
    imgui.WindowFlags_NoScrollbar, imgui.WindowFlags_NoDocking, imgui.WindowFlags_NoTitleBar, 
    imgui.WindowFlags_NoResize, imgui.WindowFlags_NoMove, imgui.WindowFlags_NoScrollWithMouse, imgui.WindowFlags_NoCollapse
)

local function SetupStyle()
    --[[ Window Styles ]]--
    imgui.PushStyleVar1(imgui.StyleVar_WindowPadding, 0)

    --[[ Window Colours ]]--
    imgui.PushStyleColor2(imgui.Col_Border, imgui.ImVec4(0, 0, 0, 0))

    imgui.SetNextWindowBgAlpha(0.5)
end

local tabs = {
    tab_utilities = require('clutchrp.ui.tabs.tab_utilities'),
    tab_moderation = require('clutchrp.ui.tabs.tab_moderation'),
    tab_fun = require('clutchrp.ui.tabs.tab_fun')
}

local function Draw(dt)
    viewport = imgui.GetMainViewport()

    --[[ Title ]]--
    imgui.PushStyleVar1(imgui.StyleVar_WindowRounding, 0) -- this is for both windows
    imgui.SetNextWindowSize(imgui.ImVec2(windowSize.x, 30))
    imgui.SetNextWindowPos(imgui.ImVec2(viewport.Size.x / 2 - windowSize.x / 2, viewport.Size.y / 2 - windowSize.y / 2 - 30))
    if imgui.Begin('ClutchRP Moderation Title', imgui.BoolPtr(true), windowStyles) then
        imgui.SetCursorPosX((windowSize.x - imgui.CalcTextSize('Moderation').x) * 0.5)
        imgui.Text('Moderation')
        imgui.End()
    end

    SetupStyle()

    imgui.SetNextWindowPos(imgui.ImVec2(viewport.Size.x / 2 - windowSize.x / 2, viewport.Size.y / 2 - windowSize.y / 2))
    imgui.SetNextWindowSize(imgui.ImVec2(windowSize.x, windowSize.y))
    if imgui.Begin('Moderation Menu', imgui.BoolPtr(true), windowStyles) then
        imgui.PushStyleVar1(imgui.StyleVar_TabRounding, 0)
        if imgui.BeginTabBar('tab_moderation##') then
            tabs.tab_moderation.Draw(dt)
            tabs.tab_utilities.Draw(dt)
            tabs.tab_fun.Draw(dt)
        end
        imgui.PopStyleVar(1)
        imgui.End()
    end
end

M.Draw = Draw

return M