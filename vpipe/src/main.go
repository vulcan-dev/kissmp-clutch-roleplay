package main

import (
	"bufio"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	nested "github.com/antonfisher/nested-logrus-formatter"
	"github.com/sirupsen/logrus"
)

var (
	log = initializeLogger()
	debug = true
	server string
	cmd *exec.Cmd
	handler = Handler{}

	stdin io.WriteCloser
	stdout io.ReadCloser
	scanner *bufio.Scanner
	
	lastOutput string
	done = make(chan struct{})
)

func main() {
	if debug {
		server = "../server/"
		log.SetLevel(logrus.DebugLevel)
	} else {
		server = "./"
	}
	
	go handler.New()
	
	cmd = exec.Command(filepath.Join(server, "kissmp-server.exe"))
	err := setupPipes(); if err != nil {
		log.Fatalln(err)
	}
}

func output(text string) {
	if strings.Contains(text, "[DEBUG]") {
		text = strings.ReplaceAll(text, " [DEBUG]:", "")
		log.Debugln(text)
	} else if strings.Contains(text, "[INFO]") {
		text = strings.ReplaceAll(text, " [INFO]:", "")
		log.Infoln(text)
	} else if strings.Contains(text, "[ERROR]") {
		text = strings.ReplaceAll(text, " [ERROR]:", "")
		log.Errorln(text)
	} else if strings.Contains(text, "[WARN]") {
		text = strings.ReplaceAll(text, " [WARN]:", "")
		log.Warnln(text)
	} else if strings.Contains(text, "[FATAL]") {
		text = strings.ReplaceAll(text, " [FATAL]:", "")
		log.Fatalln(text)
	} else if strings.Contains(text, "[Return]") {
		lastOutput = scanner.Text()
	} else if strings.Contains(text, "[API]") {
		command := Command{}
		
		text = strings.ReplaceAll(text, "[API]:", "")
		json.Unmarshal([]byte(text), &command)
		
		handler.Handle(&command)
	}
}

// func getOut() string {
// 	scanner = bufio.NewScanner(os.Stdout)
// 	for scanner.Scan() {
// 		log.Debugln("Output: " + scanner.Text())
// 		// return scanner.Text()
// 	}
	
// 	return scanner.Text()
// }

func sendStdin(message string) string {
	if message != "" {
		fmt.Fprintf(stdin, "%s\n", string(message))
	}

	log.Debugln("lastOutput = " + lastOutput)
	return lastOutput
}

func setupPipes() error {
	cmd.Dir = filepath.Join(server)

	mstdout, err := cmd.StdoutPipe()
	if err != nil {
		return errors.New("failed reading stdout pipe. another instance may be running" + ". error: " + err.Error())
	}; stdout = mstdout

	mstdin, err := cmd.StdinPipe()
	if err != nil {
		return errors.New("failed reading stdin pipe. another instance may be running" + ". error: " + err.Error())
	}; stdin = mstdin

	cmd.Stderr = os.Stderr
	// cmd.Stdout = os.Stdout

	go func() {
		scanner = bufio.NewScanner(stdout)
		for scanner.Scan() {
			output(scanner.Text())
		}
		
		done <- struct{}{}
	}()

	go func() {
		for {
			reader := bufio.NewReader(os.Stdin)
			text, _, _ := reader.ReadLine()
			fmt.Fprintf(stdin, "%s\n", string(text))
		}
	}()

	if err = cmd.Start(); err != nil {
		return errors.New("cmd.Start() failed in f: ListenPipe" + ". error: " + err.Error())
	}

	<-done
	
	if err = cmd.Wait(); err != nil {
		return errors.New("cmd.Wait() failed in f: ListenPipe" + ". error: " + err.Error())
	}

	return nil
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