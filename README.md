## Building API
- Open a command prompt in /api/
- Run the following commands
> Note: This is for my Discord Bot that communicates with the server but it can't because sendLua is stupid. I'll leave it in here though
```sh
go run .\main.go .\server.go .\bot.go .\commands.go -VULCAN_BOT token  
```

> There are new commands that aren't in this list and some have been updated/changed. I might update it, not sure. Oh, and the first 3 commands don't exist anymore. I could remove them right now but I'm not going too :D
# Moderation Commands | Moderation

    - [Owner] kill (shutsdown server)
    - [Owner] restart (restarts server)
    - [Owner] add_key_all <key> <default_value> (adds a new key to all users in 'players.json')
    - [Owner] say <msg> (console only)

    - [Admin] set_rank <user_name or secret> <int_rank>
    - [Admin] whitelist <name> <optional_secret> (will be opposite of current value)
    - [Admin] lock (kicks all players that aren't moderators and then disabled people joining)

    - [Moderator] kick <user> <reason>
    - [Moderator] ban <user> (time)
    - [Moderator] unban <user>
    - [Moderator] mute <user> (time)
    - [Moderation] unmute <user>
    - [Moderator] freeze <user>
    - [Moderator] unfreeze <user>
    - [Moderator] warn <user> (reason)

    - [VIP] ban <user> (time : max 2h)

    - [Trusted] voteban <user> (time : max 20m)

    - [User] votemute <user> (time : max 15m)

# Utility Commands | Moderation
    - [Owner] advertise <message>

    - [Admin] time_play
    - [Admin] time_stop
    - [Admin] set_time <hour>:(min):(second)
    - [Admin] set_fog (level)
    - [Admin] set_wind (user) <x> (y) (z)

    - [Trusted] tp <user> (user2)

    - [User] help (command) (/help kick)
    - [User] report <user> <reason>
    - [User] uptime
    - [User] playtime
    - [User] home
    - [User] mods
    - [User] discord
    - [User] pm <user>
    - [User] block <user>
    - [User] unblock <user>
    - [User] getblocks
    - [User] votekick <user>
    - [User] donate

# Fun Commands | Moderation
    - [Admin] imitate <user> <message>
    - [Admin] set_gravity (specific user) <value>
    - [Admin] destroy <user>

# New commands that need sorting
    get_ids
    send_message (displays ui message in a huge ass font)
    advertise <msg>
    

## Role System

- Ranks go off of integers
- You cannot set someones rank that is higher than yours
- You cannot set your own rank
- The console can change anyones rank
- You can change ranks based off of an in-game user or their secret
- I removed the console rank but I cba updating it and formatting it to look nice so I'm going to leave it here
- Don't use my developer role because you didn't make this :)

| Rank: 0 | Rank: 1 | Rank: 2 | Rank: 3   | Rank: 4 | Rank: 5 | Rank: 6 | Rank: 7 |
|:-------:|:-------:|:-------:|:---------:|:-------:|:-------:|:-------:|:-------:|
|  User   | Trusted |   VIP   | Moderator |  Admin  |  Owner  | Console | Developer|

## Credits
Verb for helping with the testing and finding sexy lua functions :D