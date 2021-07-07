package main

import "github.com/diamondburned/arikawa/v2/discord"

type SWebhook struct {
	Type      int        `json:"type"`
	ID        uint64     `json:"id"`
	Name      string     `json:"name"`
	Avatar    string     `json:"avatar"`
	ChannelID discord.ChannelID `json:"channel_id"`
	GuildID uint64 `json:"guild_id"`
	ApplicationID uint64 `json:"app_id"`
	SourceGuild struct {
		//id, name, icon
	}

	SourceChannel struct {
		//id, name
	}

	User struct {
		//username,	disc, id, avatar, pub_flag
	}
}