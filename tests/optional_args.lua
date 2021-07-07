function table.pack(...)
    return { n = select("#", ...); ... }
end

local function LogError(error, ...)
    local stringArgs = ''
    local args = table.pack(...)

    for i = 1, args.n do
        stringArgs = stringArgs .. tostring(args[i])
    end

    print(string.format(error, stringArgs))
end

LogError('Test')