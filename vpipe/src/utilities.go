package main

import (
	"bufio"
	"bytes"
	"errors"
	"fmt"
	"os"
	"strings"
)

var buf bytes.Buffer

func Output(text string) {
	if strings.Contains(text, "[DEBUG]") { // debug
		text = strings.ReplaceAll(text, " [DEBUG]:", "")
		log.Debugln(text)
	} else if strings.Contains(text, "[INFO]") { // info
		text = strings.ReplaceAll(text, " [INFO]:", "")
		log.Infoln(text)
	} else if strings.Contains(text, "[ERROR]") { // error
		text = strings.ReplaceAll(text, " [ERROR]:", "")
		log.Errorln(text)
	} else if strings.Contains(text, "[WARN]") { // warning
		text = strings.ReplaceAll(text, " [WARN]:", "")
		log.Warnln(text)
	} else if strings.Contains(text, "[FATAL]") { // fatal
		text = strings.ReplaceAll(text, " [FATAL]:", "")
		log.Fatalln(text)
	} else if strings.Contains(text, "[API]") {
		text = strings.ReplaceAll(text, " [API]:", "")
		fmt.Println(text)
	}
}

func GetStdout() {
	scanner := bufio.NewScanner(os.Stdout)
	for scanner.Scan() {
		Output(buf.String())
	}
}

func SetupPipes() error {
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	
	// go GetStdout()
	
	// start the command
	if err := cmd.Start(); err != nil {
		return errors.New("cmd.Start() failed in f: ListenPipe" + ". error: " + err.Error())
	};
	
	// wait so main doesn't exit unless this has finished
	// if err := cmd.Wait(); err != nil {
	// 	return errors.New("cmd.Wait() failed in f: ListenPipe" + ". error: " + err.Error())
	// }

	return nil
}