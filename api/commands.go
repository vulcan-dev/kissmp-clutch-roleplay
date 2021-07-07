package main

import (
	"fmt"
	"time"

	"github.com/diamondburned/arikawa/v2/discord"
)
type SCommands struct {
	Auth     string `json:"auth"`
	Command  string `json:"command"`

	Executor struct {
		Name string `json:"name"`
		Secret string `json:"secret"`
	} `json:"executor"`

	Client struct {
		Name string `json:"name"`
		Secret string `json:"secret"`
	} `json:"client"`
	
	TimeStr  string `json:"time_str"`
	Reason   string `json:"reason"`
	Message string `json:"message"`

	Channel discord.ChannelID `json:"channel"`
}

func (cmd *SCommands) user_ban(data SCommands) {
	embed := discord.Embed {
		Title: "Moderation [User Kicked]",
		Timestamp: discord.NowTimestamp(),
		Fields: []discord.EmbedField{
			0: {
				Name: "Moderator",
				Value: string(data.Executor.Name),
				Inline: true,
			},
			1: {
				Name: "User",
				Value: string(data.Client.Name),
				Inline: true,
			},
			2: {
				Name: "Ban Date",
				Value: fmt.Sprintf(time.Now().Format("2006-01-02 15:04:05") + " -> " + string(data.TimeStr)),
				Inline: true,
			},
		},
		Footer: &discord.EmbedFooter{Text: "Reason: " + string(data.Reason)},
		Color: 0x30D780,
		Author: &discord.EmbedAuthor{
			Name: string(bot.State.Ready().User.Username),
			Icon: discord.User.AvatarURL(bot.State.Ready().User),
		},
	}

	if _, err := bot.State.SendEmbed(data.Channel, embed); err != nil {
		log.Errorln("Failed sending embed.", err)
	}
}

func (cmd *SCommands) user_unban(data SCommands) {
	embed := discord.Embed {
		Title: "Moderation [User Unbanned]",
		Timestamp: discord.NowTimestamp(),
		Fields: []discord.EmbedField{
			0: {
				Name: "Moderator",
				Value: string(data.Executor.Name),
				Inline: true,
			},
			1: {
				Name: "User",
				Value: string(data.Client.Name),
				Inline: true,
			},
		},
		Color: 0x30D780,
		Author: &discord.EmbedAuthor{
			Name: string(bot.State.Ready().User.Username),
			Icon: discord.User.AvatarURL(bot.State.Ready().User),
		},
	}

	if _, err := bot.State.SendEmbed(data.Channel, embed); err != nil {
		log.Errorln("Failed sending embed.", err)
	}
}

func (cmd *SCommands) user_report(data SCommands) {
	embed := discord.Embed {
		Title: "Moderation [User Reported]",
		Timestamp: discord.NowTimestamp(),
		Fields: []discord.EmbedField{
			0: {
				Name: "Client",
				Value: string(data.Executor.Name),
				Inline: true,
			},
			1: {
				Name: "Reported User",
				Value: string(data.Client.Name),
				Inline: true,
			},
		},
		Footer: &discord.EmbedFooter{Text: "Reason: " + string(data.Reason)},
		Color: 0x30D780,
		Author: &discord.EmbedAuthor{
			Name: string(bot.State.Ready().User.Username),
			Icon: discord.User.AvatarURL(bot.State.Ready().User),
		},
	}

	if _, err := bot.State.SendEmbed(data.Channel, embed); err != nil {
		log.Errorln("Failed sending embed.", err)
	}
}

func (cmd *SCommands) user_kick(data SCommands) {
	embed := discord.Embed {
		Title: "Moderation [User Kicked]",
		Timestamp: discord.NowTimestamp(),
		Fields: []discord.EmbedField{
			0: {
				Name: "Moderator",
				Value: string(data.Executor.Name),
				Inline: true,
			},
			1: {
				Name: "User",
				Value: string(data.Client.Name),
				Inline: true,
			},
		},
		Footer: &discord.EmbedFooter{Text: "Reason: " + string(data.Reason)},
		Color: 0x30D780,
		Author: &discord.EmbedAuthor{
			Name: string(bot.State.Ready().User.Username),
			Icon: discord.User.AvatarURL(bot.State.Ready().User),
		},
	}

	if _, err := bot.State.SendEmbed(data.Channel, embed); err != nil {
		log.Errorln("Failed sending embed.", err)
	}
}

func (cmd *SCommands) user_chat(data SCommands) {
	if _, err := bot.State.SendMessage(data.Channel, data.Executor.Name + " said: " + data.Message, nil); err != nil {
		log.Errorln("Failed sending message.", err)
	}
}

func (cmd *SCommands) user_vehicle_spawn(data SCommands) {
	if _, err := bot.State.SendMessage(data.Channel, data.Executor.Name + " spawned a " + data.Message, nil); err != nil {
		log.Errorln("Failed sending message.", err)
	}
}

func (cmd *SCommands) user_muted(data SCommands) { // user can still speak if they're muted, needs fixing
	embed := discord.Embed {
		Title: "Moderation [User Muted]",
		Timestamp: discord.NowTimestamp(),
		Fields: []discord.EmbedField{
			0: {
				Name: "Moderator",
				Value: string(data.Executor.Name),
				Inline: true,
			},
			1: {
				Name: "User",
				Value: string(data.Client.Name),
				Inline: true,
			},
			2: {
				Name: "Unmute Date",
				Value: fmt.Sprintf(time.Now().Format("2006-01-02 15:04:05") + " -> " + string(data.TimeStr)),
				Inline: true,
			},
		},
		Footer: &discord.EmbedFooter{Text: "Reason: " + string(data.Reason)},
		Color: 0x30D780,
		Author: &discord.EmbedAuthor{
			Name: string(bot.State.Ready().User.Username),
			Icon: discord.User.AvatarURL(bot.State.Ready().User),
		},
	}

	if _, err := bot.State.SendEmbed(data.Channel, embed); err != nil {
		log.Errorln("Failed sending embed.", err)
	}
}

func (cmd *SCommands) user_unmuted(data SCommands) { // user can still speak if they're muted, needs fixing
	embed := discord.Embed {
		Title: "Moderation [User Unmuted]",
		Timestamp: discord.NowTimestamp(),
		Fields: []discord.EmbedField{
			0: {
				Name: "Moderator",
				Value: string(data.Executor.Name),
				Inline: true,
			},
			1: {
				Name: "User",
				Value: string(data.Client.Name),
				Inline: true,
			},
		},
		Color: 0x30D780,
		Author: &discord.EmbedAuthor{
			Name: string(bot.State.Ready().User.Username),
			Icon: discord.User.AvatarURL(bot.State.Ready().User),
		},
	}

	if _, err := bot.State.SendEmbed(data.Channel, embed); err != nil {
		log.Errorln("Failed sending embed.", err)
	}
}

func (cmd *SCommands) user_user_joined(data SCommands) {
	if _, err := bot.State.SendMessage(data.Channel, data.Client.Name + " has joined the server", nil); err != nil {
		log.Errorln("Failed sending message.", err)
	}
}

func (cmd *SCommands) user_user_left(data SCommands) {
	if _, err := bot.State.SendMessage(data.Channel, data.Client.Name + " has left the server", nil); err != nil {
		log.Errorln("Failed sending message.", err)
	}
}

func (cmd *SCommands) user_warn(data SCommands) {
	embed := discord.Embed {
		Title: "Moderation [User Warned]",
		Timestamp: discord.NowTimestamp(),
		Fields: []discord.EmbedField{
			0: {
				Name: "Moderator",
				Value: string(data.Executor.Name),
				Inline: true,
			},
			1: {
				Name: "User",
				Value: string(data.Client.Name),
				Inline: true,
			},
		},
		Color: 0x30D780,
		Footer: &discord.EmbedFooter{Text: "Reason: " + string(data.Reason)},
		Author: &discord.EmbedAuthor{
			Name: string(bot.State.Ready().User.Username),
			Icon: discord.User.AvatarURL(bot.State.Ready().User),
		},
	}

	if _, err := bot.State.SendEmbed(data.Channel, embed); err != nil {
		log.Errorln("Failed sending embed.", err)
	}
}