local G_Clients = {['id'] = {rank = function() return 101 end}}

function copy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
    return res
end

local clients = copy(G_Clients)

for k, v in pairs(clients) do clients[k].rank = clients[k].rank() end

print(clients['id'].rank)