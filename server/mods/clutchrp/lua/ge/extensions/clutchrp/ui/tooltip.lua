local M = {}

local imgui = ui_imgui

M.shouldDraw = false
M.drawData = {
    message = ''
}

local viewport = imgui.GetMainViewport()
local windowSize = {
    x = 480,
    y = 140
}

local windowStyles = bit.bor(
    imgui.WindowFlags_NoScrollbar, imgui.WindowFlags_NoDocking, imgui.WindowFlags_NoTitleBar, 
    imgui.WindowFlags_NoResize, imgui.WindowFlags_NoMove, imgui.WindowFlags_NoScrollWithMouse, imgui.WindowFlags_NoCollapse
)

local function Draw(dt)
    if M.drawData and M.drawData.message and M.drawData.message ~= '' then
        viewport = imgui.GetMainViewport()
        imgui.PushStyleVar1(imgui.StyleVar_WindowRounding, 0)
        imgui.PushStyleColor2(imgui.Col_Border, imgui.ImVec4(0, 0, 0, 0))
        imgui.SetNextWindowSize(imgui.ImVec2(windowSize.x, 30))
        imgui.SetNextWindowPos(imgui.ImVec2(viewport.Size.x / 2 - windowSize.x / 2, 30))
        imgui.SetNextWindowBgAlpha(0.5)
        if imgui.Begin('Tooltip', imgui.BoolPtr(true), windowStyles) then
            imgui.SetCursorPosX((windowSize.x - imgui.CalcTextSize(M.drawData.message).x) * 0.5)
            imgui.Text(M.drawData.message)
            imgui.End()
        end

        imgui.PopStyleVar(1)
    end
end

M.Draw = Draw

return M