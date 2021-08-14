local M = {}

require('Addons.VK.globals')

local currentFires = {}

local function StartFire(client, position)
    if not currentFires[client.user:getName()] then currentFires[client.user:getName()] = { count = 0 } end
    currentFires[client.user:getName()].count = currentFires[client.user:getName()].count + 1
    currentFires[client.user:getName()]['P_CRPFire' .. currentFires[client.user:getName()].count] = {
        x = position[1],
        y = position[2],
        z = position[3]
    }

    for _, c in pairs(G_Clients) do
        c.user:sendLua(G_LuaFormat(string.format([[
            P_CRPFire = createObject('ParticleEmitterNode')
            P_CRPFire.name = 'P_CRPFire%s'
            P_CRPFire:setField('emitter', 0, "BNGP_31")
            P_CRPFire:setField('position', 0, "%.6f %.6f %.6f")
            P_CRPFire:registerObject('P_CRPFire%s')
            P_CRPFire:setField('dataBlock', 0, 'lightExampleEmitterNodeData1')
        ]], currentFires[client.user:getName()].count, position[1], position[2], position[3], currentFires[client.user:getName()].count)))
    end

    -- for _, c in pairs(G_Clients) do
    --     c.user:sendLua(G_LuaFormat(string.format([[
    --         P_CRPSmoke = createObject('ParticleEmitterNode')
    --         P_CRPSmoke.name = 'P_CRPSmoke%s'
    --         P_CRPSmoke:setField('emitter', 0, "BNGP_32")
    --         P_CRPSmoke:setField('position', 0, "%.6f %.6f %.6f")
    --         P_CRPSmoke:registerObject('P_CRPSmoke%s')
    --         P_CRPSmoke:setField('dataBlock', 0, 'lightExampleEmitterNodeData1')
    --     ]], currentFires[client.user:getName()].count, position[1], position[2], position[3], currentFires[client.user:getName()].count)))
    -- end
end

local function GetFires(client)
    if not client then return currentFires end

    local tbl = {}

    for k, v in pairs(currentFires[client.user:getName()]) do
        if type(v) == table then
            tbl[k] = v
        end
    end

    return tbl
end

local function Extinguish(name)
    for user, tbl in pairs(currentFires) do
        for fireName, fire in pairs(tbl) do
            if name == fireName then
                currentFires[user].count = currentFires[user].count - 1
                table.remove(currentFires, 1)
            end
        end
    end

    for _, client in pairs(G_Clients) do
        client.user:sendLua(string.format('deleteObject("%s")', name))
        -- client.user:sendLua(string.format('deleteObject("%s")', 'P_CRPSmoke'..string.sub(name, -1)))
    end
end

M.StartFire = StartFire
M.GetFires = GetFires
M.Extinguish = Extinguish

return M