# Instructions
### Necessary Files & Folders
/logs/  
/settings/server.json
```json
{
    "log": {
        "verbose": true,
        "file": true
    },

    "options": {
        "kick_unknown": true,
        "whitelist_all": true,
        "command_prefix": "/",
        "player_location": "./addons/vulcan_script/settings/",
        "colour_location": "./addons/vulcan_script/settings/",
        "extensions": ["vulcan_rp", "vulcan_moderation"]
    }
}
```

/settings/players.json
```json
{

}
```

/settings/colours.json
```language
{
    "Developer": { "r": 33, "g": 215, "b": 135 },
    "Owner": { "r": 231, "g": 76, "b": 60 },
    "Admin": { "r": 46, "g": 204, "b": 113 },
    "Moderator": { "r": 230, "g": 126, "b": 34 },
    "VIP": { "r": 1, "g": 1, "b": 1 },
    "Trusted": { "r": 166, "g": 122, "b": 79 },
    "User": { "r": 255, "g": 255, "b": 255 },

    "Success": { "r": 0, "g": 0, "b": 0 },
    "Warning": { "r": 0, "g": 0, "b": 0 },
    "Error": { "r": 0, "g": 0, "b": 0 }
}
```