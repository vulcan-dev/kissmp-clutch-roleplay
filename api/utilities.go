package main

import (
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	nested "github.com/antonfisher/nested-logrus-formatter"
	"github.com/sirupsen/logrus"
)

type Utilities struct{}

func (u *Utilities) WriteLine(line string) string {
	currentTime := time.Now()
	out := ""

	if strings.Contains(line, "DEBUG") {
		out = strings.ReplaceAll(line, "[DEBUG]: ", "")
		out = strings.ReplaceAll(out, "["+currentTime.Format("2006-01-02 15:04:05")+"]", "")
		log.Infoln(out)
	} else if strings.Contains(line, "INFO") {
		log.Infoln(line)
	}

	return out
}

func (u *Utilities) SetupCloseHandler() {
	c := make(chan os.Signal)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-c
		log.Infoln("Shutting Down Server")
		os.Exit(0)
	}()
}

func (u *Utilities) InitializeLogger() *logrus.Logger {
	log := logrus.New()
	log.SetFormatter(&nested.Formatter{
		HideKeys:    false,
		TimestampFormat: "2006-01-02 15:04:05",
		TrimMessages: true,
	})

	log.SetOutput(os.Stdout)
	log.Level = logrus.InfoLevel

	return log
}