package main

import (
	"errors"
	"os"
	"os/signal"
	"strings"

	"github.com/bwmarrin/discordgo"
)

var (
	prefix = "/"
)

type Handler struct{}

type Command struct {
	Executor struct {
		Name   string  `json:"Name"`
		ID     float32 `json:"ID"`
		MID    float32 `json:"MID"`
		Secret string  `json:"Secret"`
	} `json:"Executor"`

	Client struct {
		Name   string  `json:"Name"`
		ID     float32 `json:"ID"`
		MID    float32 `json:"MID"`
		Secret string  `json:"Secret"`
	} `json:"Client"`

	Data string `json:"Data"`
	Type string `json:"Type"`
}

func (handler *Handler) New() error {
	s, err := discordgo.New("Bot " + "Nzk1NDU0MTMxNTczNjIwNzY2.X_JmYw.nDphoF314DeSdVjEI2NBOfGYwdk")
	if err != nil {
		return errors.New("failed creating discord bot. error: " + err.Error())
	}
	
	s.AddHandler(messageCreate)
	s.AddHandler(func(s *discordgo.Session, r *discordgo.Ready) {
		log.Infoln("Vulcan is online")
	})
	
	if err := s.Open(); err != nil {
		return errors.New("failed opening the discord websocket")
	};
	
	defer s.Close()
		
	stop := make(chan os.Signal)
	signal.Notify(stop, os.Interrupt)
	<-stop
	
	return nil
}

func (handler *Handler) Handle(command* Command) {}

func messageCreate(s *discordgo.Session, m *discordgo.MessageCreate) {
	if m.Author.ID == s.State.User.ID { return }
	
	args := strings.Fields(m.Content)
	if args[0][0] == '-' {
		command := string(strings.Join(args, " "))
		command = strings.ReplaceAll(command, "-", "/")
		s.ChannelMessageSend(m.ChannelID, sendStdin(command))
	}
}