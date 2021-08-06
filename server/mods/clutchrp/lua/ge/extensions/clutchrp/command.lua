-- !READ
--[[
    I know most of this is a mess, I'm planning on a refactor to fix all bugs I see <:
]]

local M = {}

M.imgui = ui_imgui

M.commands = {}

M.buttonSize = M.imgui.ImVec2(100, 30)

M.windowSize = {
    x = 700,
    y = 500
}

M.windowStyles = bit.bor(
    M.imgui.WindowFlags_NoScrollbar, M.imgui.WindowFlags_NoDocking, M.imgui.WindowFlags_NoTitleBar, 
    M.imgui.WindowFlags_NoResize, M.imgui.WindowFlags_NoMove, M.imgui.WindowFlags_NoScrollWithMouse, M.imgui.WindowFlags_NoCollapse
)

local function Execute(command)
    if network and network.connection.connected and string.find(network.connection.server_info.name, 'Clutch Roleplay') then
        network.send_data({Chat = command}, true)
    else
        log('E', 'clutchrp', 'you tried sending "'..command..'" but you are not on Clutch Roleplay')
    end
end

M.drawData = {
    window = {}
}

local canDraw = false
M.viewport = nil

local function Set(data)
    if data then
        for k, v in pairs(data) do
            print(k .. ' ' .. tostring(v))
        end

        M.drawData.shouldDraw = data.shouldDraw or false
        M.drawData.drawFunction = data.drawFunction
        M.drawData.command = data.command or nil
        M.drawData.window.size = data.window.size or M.imgui.ImVec2(800, 600)
        M.drawData.window.sizeTitle = data.window.sizeTitle or M.imgui.ImVec2(M.drawData.window.size.x, 30)
        M.drawData.window.posTitle = data.window.posTitle or M.imgui.ImVec2(M.viewport.Size.x / 2 - M.drawData.window.size.x / 2, M.viewport.Size.y / 2 - M.drawData.window.size.y / 2)
        M.drawData.window.style = data.window.style or 0
        M.drawData.window.title = data.window.title or ''

        canDraw = true
    end
end


local function Draw(data)
    local viewport = M.imgui.GetMainViewport()
    M.viewport = viewport

    if canDraw and M.drawData.shouldDraw then
        --[[ Window Title ]]--
        M.imgui.SetNextWindowSize(M.drawData.window.sizeTitle)

        M.imgui.SetNextWindowPos(M.drawData.window.posTitle)
        if M.imgui.Begin(M.drawData.window.title .. '_title', M.imgui.BoolPtr(true), M.drawData.window.style) then
            M.imgui.SetCursorPosX((M.drawData.window.sizeTitle.x - M.imgui.CalcTextSize(M.drawData.window.title).x) * 0.5)
            M.imgui.Text(M.drawData.window.title)
            M.imgui.End()
        end

        --[[ Actual Window ]]--
        M.imgui.SetNextWindowBgAlpha(0.5)
        M.imgui.SetNextWindowSize(M.imgui.ImVec2(M.drawData.window.sizeTitle.x, M.drawData.window.size.y))
        M.imgui.SetNextWindowPos(M.imgui.ImVec2(M.drawData.window.posTitle.x, M.drawData.window.posTitle.y + 30))

        if M.imgui.Begin(M.drawData.window.title, M.imgui.BoolPtr(true), M.drawData.window.style) then
            M.drawData.drawFunction()
            M.imgui.End()
        end

        if M.drawData.shouldDraw2 and M.drawData.drawFunction2 then
            M.drawData.drawFunction2()
        end

        M.imgui.SetNextWindowBgAlpha(1)
    end
end

local buffer = M.imgui.ArrayChar(512)
local buffer2 = M.imgui.ArrayChar(512)
local buffer3 = M.imgui.ArrayChar(512)

M.commands['911'] = function()
    M.imgui.PushItemWidth(M.drawData.window.size.x - 2)
    M.imgui.SetCursorPosY(M.drawData.window.size.y / 2 - 10)
    if M.imgui.InputText('##crp_police', buffer, nil, M.imgui.InputTextFlags_EnterReturnsTrue) then
        Execute('/911 ' .. ffi.string(buffer))
        buffer = M.imgui.ArrayChar(512)
    end
    M.imgui.PopItemWidth()
end

local buttonSize = M.imgui.ImVec2(100, 30)

M.commands['get_roles'] = function()
    M.imgui.Columns(4, 'player_column', false)

    for id, client in pairs(network.players) do
        M.imgui.SetCursorPosX((M.imgui.GetCursorPosX() + M.imgui.GetColumnWidth() - buttonSize.x) - 15)
        if M.imgui.Button(client.name, buttonSize) then
            Execute('/get_roles ' .. id)
        end

        M.imgui.NextColumn()
    end
end

M.commands['ui_same'] = function()
    M.imgui.PushItemWidth(M.drawData.window.sizeTitle.x - 2)
    M.imgui.SetCursorPosY(M.drawData.window.size.y / 2 - 10)
    if M.imgui.InputText('##crp_set_time', buffer, nil, M.imgui.InputTextFlags_EnterReturnsTrue) then
        if M.drawData.command then
            Execute('/' .. M.drawData.command .. ' ' .. ffi.string(buffer)) 
            buffer = M.imgui.ArrayChar(512)
        end
    end
    M.imgui.PopItemWidth()
end

local testPlayers = {
    [1] = {
        name = 'Daniel W'
    },
    [2] = {
        name = 'Yes'
    },
    [3] = {
        name = 'Zero'
    },
    [4] = {
        name = 'Verb'
    },
    [5] = {
        name = 'Name1'
    },
    [6] = {
        name = 'Name2'
    },
    [7] = {
        name = 'Name3'
    },
    [8] = {
        name = 'Name4'
    },
    [9] = {
        name = 'Name5'
    },
    [10] = {
        name = 'Name6'
    },
    [11] = {
        name = 'Name7'
    },
    [12] = {
        name = 'Name8'
    }
}

if not network then
    network = {}
    network.connection = {}
    network.connection.connected = false
    network.players = testPlayers
end

M.commands['teleport_to'] = function()
    M.imgui.Columns(4, 'player_column_tp_to', false)

    for id, client in pairs(network.players) do
        M.imgui.SetCursorPosX((M.imgui.GetCursorPosX() + M.imgui.GetColumnWidth() - buttonSize.x) - buttonSize.x / 2)
        if M.imgui.Button(client.name, buttonSize) then
            Execute('/tp ' .. id)
        end

        M.imgui.NextColumn()
    end
end

local client1
local client2
M.commands['teleport_user_to'] = function()
    M.imgui.Columns(4, 'player_column_tp_user_to', false)

    for id, client in pairs(network.players) do
        M.imgui.SetCursorPosX((M.imgui.GetCursorPosX() + M.imgui.GetColumnWidth() - buttonSize.x) - buttonSize.x / 2)
        if M.imgui.Button(client.name, buttonSize) then
            if client1 and client2 then client1 = nil client2 = nil end

            if not client1 then
                client1 = id
            else
                if client1 ~= client2 then
                    client2 = id
                    Execute('/tp ' .. client1 .. ' ' .. client2)
                end
            end
        end

        M.imgui.NextColumn()
    end
end

M.commands['delete_vehicle'] = function()
    M.imgui.Columns(4, 'player_column_dv', false)

    for id, client in pairs(network.players) do
        M.imgui.SetCursorPosX((M.imgui.GetCursorPosX() + M.imgui.GetColumnWidth() - buttonSize.x) - buttonSize.x / 2)
        if M.imgui.Button(client.name, buttonSize) then
            Execute('/dv ' .. id)
        end

        M.imgui.NextColumn()
    end
end

M.commands['delete_all_user_vehicles'] = function()
    M.imgui.Columns(4, 'player_column_dva', false)

    for id, client in pairs(network.players) do
        M.imgui.SetCursorPosX((M.imgui.GetCursorPosX() + M.imgui.GetColumnWidth() - buttonSize.x) - buttonSize.x / 2)
        if M.imgui.Button(client.name, buttonSize) then
            Execute('/dva ' .. id)
        end

        M.imgui.NextColumn()
    end
end

local showOther = false

M.commands['ban'] = function()
    M.imgui.Columns(4, 'player_ban_column', false)

    for id, client in pairs(network.players) do
        M.imgui.SetCursorPosX((M.imgui.GetCursorPosX() + M.imgui.GetColumnWidth() - buttonSize.x) - 15)
        if M.imgui.Button(client.name, buttonSize) then
            showOther = not showOther
        end

        M.imgui.NextColumn()
    end

    if showOther then
        M.imgui.Columns(1)
        M.imgui.PushItemWidth(M.drawData.window.sizeTitle.x / 2 - 50)
        M.imgui.SetCursorPos(M.imgui.ImVec2(5, M.drawData.window.size.y - 30))
        if M.imgui.InputText('##reason', buffer, nil, M.imgui.InputTextFlags_EnterReturnsTrue) then

        end
        M.imgui.PopItemWidth()

        M.imgui.PushItemWidth(M.drawData.window.sizeTitle.x / 2 - 50)
        M.imgui.SetCursorPos(M.imgui.ImVec2(M.drawData.window.sizeTitle.x / 2 + 50, M.drawData.window.size.y - 30))
        if M.imgui.InputText('##time', buffer2, nil, M.imgui.InputTextFlags_EnterReturnsTrue) then

        end
        M.imgui.PopItemWidth()
    end
end

M.commands['unban'] = function()
    M.imgui.PushItemWidth(M.drawData.window.sizeTitle.x - 2)
    M.imgui.SetCursorPosY(M.drawData.window.size.y / 2 - 10)
    if M.imgui.InputText('##crp_unban', buffer, nil, M.imgui.InputTextFlags_EnterReturnsTrue) then
        Execute('/unban ' .. ffi.string(buffer))
        buffer = M.imgui.ArrayChar(512)
    end
    M.imgui.PopItemWidth()
end

M.commands['kick'] = function()
    M.imgui.Columns(4, 'player_kick_column', false)

    for id, client in pairs(network.players) do
        M.imgui.SetCursorPosX((M.imgui.GetCursorPosX() + M.imgui.GetColumnWidth() - buttonSize.x) - 15)
        if M.imgui.Button(client.name, buttonSize) then
            client1 = id -- will need to rework all this because client1 will stay
            showOther = not showOther
        end

        M.imgui.NextColumn()
    end

    if showOther then
        M.imgui.Columns(1)
        M.imgui.PushItemWidth(M.drawData.window.sizeTitle.x - 2)
        M.imgui.SetCursorPosY(M.drawData.window.size.y - 30)
        if M.imgui.InputText('##crp_kick', buffer, nil, M.imgui.InputTextFlags_EnterReturnsTrue) then
            Execute('/kick ' .. client1 .. ' ' .. ffi.string(buffer))
            buffer = M.imgui.ArrayChar(512)
        end
        M.imgui.PopItemWidth()
    end
end

M.commands['warn'] = function()
    M.imgui.Columns(4, 'player_warn_column', false)

    for id, client in pairs(network.players) do
        M.imgui.SetCursorPosX((M.imgui.GetCursorPosX() + M.imgui.GetColumnWidth() - buttonSize.x) - 15)
        if M.imgui.Button(client.name, buttonSize) then
            client1 = id -- will need to rework all this because client1 will stay
            showOther = not showOther
        end

        M.imgui.NextColumn()
    end

    if showOther then
        M.imgui.Columns(1)
        M.imgui.PushItemWidth(M.drawData.window.sizeTitle.x - 2)
        M.imgui.SetCursorPosY(M.drawData.window.size.y - 30)
        if M.imgui.InputText('##crp_warn', buffer, nil, M.imgui.InputTextFlags_EnterReturnsTrue) then
            Execute('/warn ' .. client1 .. ' ' .. ffi.string(buffer))
            buffer = M.imgui.ArrayChar(512)
        end
        M.imgui.PopItemWidth()
    end
end

M.commands['remove_warn'] = function()
    M.imgui.Columns(4, 'player_remove_warn_column', false)

    for id, client in pairs(network.players) do
        M.imgui.SetCursorPosX((M.imgui.GetCursorPosX() + M.imgui.GetColumnWidth() - buttonSize.x) - 15)
        if M.imgui.Button(client.name, buttonSize) then
            client1 = id -- will need to rework all this because client1 will stay
            showOther = not showOther
        end

        M.imgui.NextColumn()
    end

    if showOther then
        M.imgui.Columns(1)
        M.imgui.PushItemWidth(M.drawData.window.sizeTitle.x - 2)
        M.imgui.SetCursorPosY(M.drawData.window.size.y - 30)
        if M.imgui.InputText('##crp_remove_warn', buffer, nil, M.imgui.InputTextFlags_EnterReturnsTrue) then
            Execute('/remove_warn ' .. client1 .. ' ' .. ffi.string(buffer))
            buffer = M.imgui.ArrayChar(512)
        end
        M.imgui.PopItemWidth()
    end
end

M.commands['set_rank'] = function()
    M.imgui.Columns(4, 'player_set_rank_player_column', false)

    for id, client in pairs(network.players) do
        M.imgui.SetCursorPosX((M.imgui.GetCursorPosX() + M.imgui.GetColumnWidth() - buttonSize.x) - 15)
        if M.imgui.Button(client.name, buttonSize) then
            client1 = id -- will need to rework all this because client1 will stay
            showOther = not showOther
        end

        M.imgui.NextColumn()
    end

    if showOther then
        M.imgui.Columns(4, 'player_set_rank_column', false)
        M.imgui.PushItemWidth(M.drawData.window.sizeTitle.x - 2)
        M.imgui.SetCursorPosY(M.drawData.window.size.y - 30)
        if M.imgui.Button('User', buttonSize) then
            Execute('/set_rank ' .. client1 .. ' 0')
        end
        M.imgui.NextColumn()
        if M.imgui.Button('Trusted', buttonSize) then
            Execute('/set_rank ' .. client1 .. ' 1')
        end
        M.imgui.NextColumn()
        if M.imgui.Button('VIP', buttonSize) then
            Execute('/set_rank ' .. client1 .. ' 2')
        end
        M.imgui.NextColumn()
        if M.imgui.Button('Moderator', buttonSize) then
            Execute('/set_rank ' .. client1 .. ' 3')
        end
        M.imgui.NextColumn()
        if M.imgui.Button('Admin', buttonSize) then
            Execute('/set_rank ' .. client1 .. ' 4')
        end
        M.imgui.NextColumn()
        M.imgui.PopItemWidth()
    end
end

M.commands['mute'] = function()
    M.imgui.Columns(4, 'player_mute_column', false)

    for id, client in pairs(network.players) do
        M.imgui.SetCursorPosX((M.imgui.GetCursorPosX() + M.imgui.GetColumnWidth() - buttonSize.x) - 15)
        if M.imgui.Button(client.name, buttonSize) then
            client1 = id -- will need to rework all this because client1 will stay
            showOther = not showOther
        end

        M.imgui.NextColumn()
    end

    if showOther then
        M.imgui.Columns(1)
        M.imgui.PushItemWidth(M.drawData.window.sizeTitle.x - 2)
        M.imgui.SetCursorPosY(M.drawData.window.size.y - 30)
        if M.imgui.InputText('##crp_mute', buffer, nil, M.imgui.InputTextFlags_EnterReturnsTrue) then
            Execute('/mute ' .. client1 .. ' ' .. ffi.string(buffer))
            buffer = M.imgui.ArrayChar(512)
        end
        M.imgui.PopItemWidth()
    end
end

M.commands['unmute'] = function()
    M.imgui.Columns(4, 'player_unmute_column', false)

    for id, client in pairs(network.players) do
        M.imgui.SetCursorPosX((M.imgui.GetCursorPosX() + M.imgui.GetColumnWidth() - buttonSize.x) - 15)
        if M.imgui.Button(client.name, buttonSize) then
            Execute('/unmute ' .. id)
        end

        M.imgui.NextColumn()
    end
end

M.commands['display_message'] = function()
    M.imgui.Columns(4, 'player_send_message_column', false)

    for id, client in pairs(network.players) do
        M.imgui.SetCursorPosX((M.imgui.GetCursorPosX() + M.imgui.GetColumnWidth() - buttonSize.x) - 15)
        if M.imgui.Button(client.name, buttonSize) then
            client1 = id -- will need to rework all this because client1 will stay
            showOther = not showOther
        end

        M.imgui.NextColumn()
    end

    if showOther then
        M.imgui.Columns(1)
        M.imgui.PushItemWidth(M.drawData.window.sizeTitle.x - 2)
        M.imgui.SetCursorPosY(M.drawData.window.size.y - 30)
        if M.imgui.InputText('##crp_send_message', buffer, nil, M.imgui.InputTextFlags_EnterReturnsTrue) then
            Execute('/send_message ' .. client1 .. ' ' .. ffi.string(buffer))
            buffer = M.imgui.ArrayChar(512)
        end
        M.imgui.PopItemWidth()
    end
end

M.commands['imitate'] = function()
    M.imgui.Columns(4, 'player_imitate_column', false)

    for id, client in pairs(network.players) do
        M.imgui.SetCursorPosX((M.imgui.GetCursorPosX() + M.imgui.GetColumnWidth() - buttonSize.x) - 15)
        if M.imgui.Button(client.name, buttonSize) then
            client1 = id -- will need to rework all this because client1 will stay
            showOther = not showOther
        end

        M.imgui.NextColumn()
    end

    if showOther then
        M.imgui.Columns(1)
        M.imgui.PushItemWidth(M.drawData.window.sizeTitle.x - 2)
        M.imgui.SetCursorPosY(M.drawData.window.size.y - 30)
        if M.imgui.InputText('##crp_imitate', buffer, nil, M.imgui.InputTextFlags_EnterReturnsTrue) then
            Execute('/imitate ' .. client1 .. ' ' .. ffi.string(buffer))
            buffer = M.imgui.ArrayChar(512)
        end
        M.imgui.PopItemWidth()
    end
end

M.commands['transfer'] = function()
    M.imgui.Columns(4, 'player_column', false)

    for id, client in pairs(network.players) do
        M.imgui.SetCursorPosX((M.imgui.GetCursorPosX() + M.imgui.GetColumnWidth() - buttonSize.x) - 15)
        if M.imgui.Button(client.name, buttonSize) then
            M.drawData.shouldDraw2 = not M.drawData.shouldDraw2
            M.drawData.drawFunction2 = function()
                if M.imgui.Begin('Bank Transfer', M.imgui.BoolPtr(true), M.drawData.window.style) then
                    M.imgui.PushItemWidth(M.drawData.window.size.x / 2)
                    M.imgui.SetCursorPos(M.imgui.ImVec2(M.drawData.window.size.x / 4, M.drawData.window.size.y - 30))
                    if M.imgui.InputText('##crp_police', buffer, nil, M.imgui.InputTextFlags_EnterReturnsTrue) then
                        Execute('/transfer ' .. id .. ' ' .. ffi.string(buffer))
                        buffer = M.imgui.ArrayChar(512)
                    end
                    M.imgui.PopItemWidth()
                end
            end
        end

        M.imgui.NextColumn()
    end
end

M.Set = Set
M.Draw = Draw
M.Execute = Execute

return M