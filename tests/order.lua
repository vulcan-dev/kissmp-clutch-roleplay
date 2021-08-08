local tbl = {
    ['a'] = 1,
    ['b'] = 2,
    ['c'] = 3,
    ['d'] = 4,
    ['e'] = 5,
    ['f'] = 6
}

local t = {}
for k, v in pairs(tbl) do
    table.insert(t, {k, v})
end

table.sort( t, function (a, b)
    return a[2] < b[2]
end )

for k, v in pairs(t) do
    print(t[k][1])
end