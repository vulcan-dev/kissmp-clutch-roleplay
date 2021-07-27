package main

import (
	"os"
	"os/exec"
	"os/signal"
	"syscall"

	nested "github.com/antonfisher/nested-logrus-formatter"
	"github.com/sirupsen/logrus"
)

var (
	log = initializeLogger()
	cmd *exec.Cmd
)

// TODO look at the installer, I got output working for both

func main() {
	setupCloseHandler()
	log.SetLevel(logrus.DebugLevel)
	
	cmd = exec.Command("../server/kissmp-server.exe")
	cmd.Dir = "../server/"
	err := SetupPipes(); if err != nil {
		log.Fatalln(err)
	}
	
	log.Infoln("Test")
}

func setupCloseHandler() {
	c := make(chan os.Signal)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-c
		if err := cmd.Process.Release(); err != nil {
			log.Errorln(err.Error())
		}
		
		log.Infoln("Closing Bridge.")
		os.Exit(0)
	}()
}

func initializeLogger() *logrus.Logger {
	log := logrus.New()
	log.SetLevel(logrus.DebugLevel)
	log.SetFormatter(&nested.Formatter{
		HideKeys:    false,
		TimestampFormat: "2006-01-02 15:04:05",
		TrimMessages: true,
	})

	return log
}