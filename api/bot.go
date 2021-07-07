package main

import (
	"os"

	"github.com/diamondburned/arikawa/v2/gateway"
	"github.com/diamondburned/arikawa/v2/state"
)

type SBot struct {
	State *state.State
	VULCAN_BOT string
}

func (bot* SBot) new() {
	s, err := state.New("Bot " + bot.VULCAN_BOT); if err != nil {
		log.Errorln("Error in state.New(): ", err)
		os.Exit(1)
	}

	bot.State = s

	bot.State.AddHandler(func(c *gateway.MessageCreateEvent) {
		if bot.State.Ready().User.ID != c.Author.ID {
			log.Debugln(c.Author.Username, "sent", c.Content)
		}
	})

	bot.State.Gateway.AddIntents(gateway.IntentGuildMessages)
	bot.State.Gateway.AddIntents(gateway.IntentDirectMessages)

	if err := s.Open(); err != nil {
		log.Errorln("Failed to connect:", err)
	}
	//defer s.Close()

	u, err := s.Me()
	if err != nil {
		log.Errorln("Failed to get myself:", err)
		os.Exit(1)
	}

	log.Infoln("Discord: Started as", u.Username)
}