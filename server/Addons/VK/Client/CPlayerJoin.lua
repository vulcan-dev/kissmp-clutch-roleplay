local M = {}

local function SetGlobals()
    return [[
        envObjectIdCache = {}
        function getObject(className, preferredObjName)
            if envObjectIdCache[className] then
                return scenetree.findObjectById(envObjectIdCache[className])
            end
            
            envObjectIdCache[className] = 0
            local objNames = scenetree.findClassObjects(className)
            if objNames and tableSize(objNames) > 0 then
                for _,name in pairs(objNames) do
                    local obj = scenetree.findObject(name)
                    if obj and (name == preferredObjName or not preferredObjName) then
                        envObjectIdCache[className] = obj:getID()
                        return obj
                    end
                end
            else
                local obj = scenetree.findObject(className)
                if obj then
                    envObjectIdCache[className] = obj:getID()
                    return obj
                end
            end
        
            return nil
        end
    ]]
end

local lua = [[]]

lua = string.gsub(lua, '    ', ' ')
lua = string.gsub(lua, '\n', ' ')

M.SetGlobals = SetGlobals
M.lua = lua

return M