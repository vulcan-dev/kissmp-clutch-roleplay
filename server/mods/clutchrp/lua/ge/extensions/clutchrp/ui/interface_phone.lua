local M = {}

local shouldDraw = false

local imgui = ui_imgui
local imu = require('ui/imguiUtils') -- hehe, found it
local viewport = imgui.GetMainViewport()

local window = {
    size = {
        width = 200,
        height = 300
    },
    style = bit.bor(
        imgui.WindowFlags_NoScrollbar, imgui.WindowFlags_NoDocking, imgui.WindowFlags_NoTitleBar, 
        imgui.WindowFlags_NoResize, imgui.WindowFlags_NoMove, imgui.WindowFlags_NoScrollWithMouse, imgui.WindowFlags_NoCollapse, imgui.WindowFlags_NoBackground
    ),

    pos = {}
}

local function SetupStyle()
    --[[ Window Styles ]]--
    -- imgui.PushStyleVar1(imgui.StyleVar_WindowPadding, 0)

    --[[ Window Colours ]]--
    -- imgui.PushStyleColor2(imgui.Col_Border, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor2(imgui.Col_Button, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor2(imgui.Col_ButtonHovered, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor2(imgui.Col_ButtonActive, imgui.ImVec4(0, 0, 0, 0))

    imgui.SetNextWindowBgAlpha(0.5)
end

local function PopStyle()
    -- imgui.PopStyleVar(1)
    imgui.SetNextWindowBgAlpha(1)
end

local function OnExtensionLoaded()
    if FS:fileExists("lua/ge/extensions/clutchrp/assets/iphone/iphone2.png") then
        M.phoneTexture = imu.texObj("lua/ge/extensions/clutchrp/assets/iphone/iphone2.png")
        log('I', 'phone', 'found image')
    else
        log('I', 'phone', 'unable to find image')
    end

    if FS:fileExists("lua/ge/extensions/clutchrp/assets/icons/twitter1.png") then
        M.twitterTexture = imu.texObj("lua/ge/extensions/clutchrp/assets/icons/twitter1.png")
        log('I', 'twitter', 'found image')
    else
        log('I', 'twitter', 'unable to find image')
    end

    if FS:fileExists("lua/ge/extensions/clutchrp/assets/icons/charge.png") then
        M.chargeTexture = imu.texObj("lua/ge/extensions/clutchrp/assets/icons/charge.png")
        log('I', 'charge', 'found image')
    else
        log('I', 'charge', 'unable to find image')
    end
end

local buttonSize = {
    width = 45,
    height = 20
}

local phoneSize = {
    width = 256,
    height = 440
}

local iconSize = 48

local states = {
    ['home_screen'] = {},
    ['twitter'] = {},
}

local battery = 100
local useAmount = 1 -- idle

local function DrawButtons(dt)
    if imgui.Button('Home', imgui.ImVec2(buttonSize.width, buttonSize.height)) then
        states.active = states['home_screen']
        useAmount = 1
    end
end

states.active = states['home_screen']

local curPos = {
    x = -20,
    y = 40
}

local function copy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
    return res
end

states['home_screen'].draw = function(dt)
    -- for appCount = 1, #apps do
    --     imgui.SetCursorPos(imgui.ImVec2(phoneSize.width / 2 - buttonSize.height / 2, phoneSize.height / 4 - 4 / 2))
    --     imgui.SameLine()    
    --     if imgui.ImageButton(M.twitterTexture.texId, imgui.ImVec2(iconSize, iconSize), imgui.ImVec2Zero, imgui.ImVec2One, 1, imgui.ImColorByRGB(255, 255, 255, 0).Value, imgui.ImColorByRGB(255,255,255,255).Value) then
    --         if states[apps[appCount]] then
    --             states.active = states[apps[appCount]]
    --         end
    --     end

    --     if appCount == #apps then
    --         curPos.x = -20
    --         curPos.y = 40
    --     end
    -- end

    imgui.SetCursorPos(imgui.ImVec2(20, 40))
    if imgui.ImageButton(M.twitterTexture.texId, imgui.ImVec2(iconSize, iconSize), imgui.ImVec2Zero, imgui.ImVec2One, 1, imgui.ImColorByRGB(255, 255, 255, 0).Value, imgui.ImColorByRGB(255,255,255,255).Value) then
        useAmount = 2
        states.active = states['twitter']
    end
end

-- imgui.BeginChild1("Scrolling", imgui.ImVec2(0, 0), false) ???

local message = imgui.ArrayChar(128)

-- message, time sent

local messages = {
    ['Daniel W'] = {
        messages = {
            ['abc'] = 1,
            ['nein'] = 2,
            ['dawniofdfwa'] = 3
        }
    },

    ['Verb'] = {
        messages = {
            ['Oi mate, guess what'] = 4
        }
    },

    ['System'] = {
        messages = {
            ['This is WIP, shoo'] = 5
        }
    }
}

local twitterStyle = bit.bor(
    imgui.WindowFlags_NoDocking, imgui.WindowFlags_NoTitleBar,
    imgui.WindowFlags_NoResize, imgui.WindowFlags_NoMove, imgui.WindowFlags_NoCollapse, imgui.WindowFlags_NoBackground
)

states['twitter'].draw = function(dt)
    imgui.SetNextWindowSize(imgui.ImVec2(phoneSize.width, phoneSize.height))
    imgui.SetNextWindowPos(imgui.ImVec2(viewport.Size.x - 256, viewport.Size.y - 440))
    imgui.SetCursorPosY(40)
    if imgui.Begin('Phone', imgui.BoolPtr(true), twitterStyle) then
        imgui.Columns(1, 'twitter_column', true)
        for user, tbl in pairs(messages) do
            for _, messageTable in pairs(tbl) do
                for message, time in pairs(messageTable) do
                    imgui.NextColumn()
                    imgui.SetCursorPosX(phoneSize.width / 2 - imgui.CalcTextSize('@' .. user .. ': ' .. message).x / 2)
                    imgui.Text('@' .. user .. ': ' .. message)
                end
            end
        end

        imgui.End()
    end

    imgui.PushItemWidth(phoneSize.width - 2)
    imgui.SetCursorPosY(phoneSize.height - 80)
    if imgui.InputText('##crp_twitter', message, nil, imgui.InputTextFlags_EnterReturnsTrue) then
        
        -- buffer = imgui.ArrayChar(512)
    end
    imgui.PopItemWidth()
end

local function Draw(dt)
    if M.shouldDraw then
        viewport = imgui.GetMainViewport()
        window.pos.x = viewport.Size.x - window.size.width / 2
        window.pos.y = viewport.Size.y - window.size.height / 2

        SetupStyle()

        imgui.SetNextWindowSize(imgui.ImVec2(phoneSize.width, phoneSize.height))
        imgui.SetNextWindowPos(imgui.ImVec2(viewport.Size.x - 256, viewport.Size.y - 440))
        if imgui.Begin('Phone', imgui.BoolPtr(true), window.style) then
            imgui.SetCursorPos(imgui.ImVec2(-2, -5))
            imgui.Image(M.phoneTexture.texId, imgui.ImVec2(phoneSize.width, phoneSize.height))
            if battery >= 1 then
                states.active.draw(dt)

                battery = battery - (useAmount / 10 * dt) / 2
                imgui.SetCursorPos(imgui.ImVec2(phoneSize.width - 60, 20))
                imgui.Text(tostring(math.floor(battery)) .. '%%')

                imgui.SetCursorPos(imgui.ImVec2(phoneSize.width / 2 - buttonSize.width / 2, phoneSize.height - 40))
                DrawButtons(dt)

                local topLeft = imgui.ImVec2(imgui.GetWindowPos().x + imgui.GetCursorPos().x - 3, imgui.GetWindowPos().y + imgui.GetCursorPos().y - imgui.GetScrollY())
                local bottomRight = imgui.ImVec2(topLeft.x + 2 * 3, topLeft.y + 3)
            else
                imgui.SetCursorPos(imgui.ImVec2(phoneSize.width / 2 - 256 / 2, phoneSize.height / 2 - 128 / 2))
                imgui.Image(M.chargeTexture.texId, imgui.ImVec2(256, 128))
            end

            imgui.End()
            PopStyle()
        end
    end
end

M.shouldDraw = shouldDraw
M.OnExtensionLoaded = OnExtensionLoaded
M.Draw = Draw

return M