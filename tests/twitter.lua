local users = {
    ['Daniel W'] = {
        messages = {
            ['abc'] = 1,
            ['ok'] = 2,
        }
    }
}

print(#users['Daniel W'].messages)

for user, tbl in pairs(users) do
    for _, messageTable in pairs(tbl) do
        for message, time in pairs(messageTable) do
        end
    end
end