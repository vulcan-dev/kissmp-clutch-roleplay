package main

import (
	"bufio"
	"encoding/json"
	"io"
	"os"
	"os/exec"
	"regexp"
	"strings"
	"sync"

	"github.com/DisgoOrg/disgohook"
	"github.com/DisgoOrg/disgohook/api"
)

var (
	utilities Utilities
	log = utilities.InitializeLogger()
	cmd *exec.Cmd
)

type Commands struct {
	Type  string `json:"type"`

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
	Data string `json:"data"`
}

type InputHandler interface {
    Input(string) error
}

type Foo struct {
	writer io.Writer
	reader io.Reader
}

func (f* Foo) Input(s string) error {
	f.writer.Write([]byte(s))
	return nil
}

func inputReader(r io.Reader, handler InputHandler) error {
    scanner := bufio.NewScanner(r)
    scanner.Split(bufio.ScanLines)

    for scanner.Scan() {
        if err := scanner.Err(); err != nil {
            return err
        }
        if err := handler.Input(scanner.Text()); err != nil {
            return err
        }
    }

    return nil
}

func main() {
	utilities.SetupCloseHandler()

	// foo := &Foo{}

    cmd = exec.Command("../server/clutch-roleplay.exe")
	cmd.Dir = "../server/"
    stdout, err := cmd.StdoutPipe()
	writer, _ := cmd.StdinPipe()
	writer.Close()

    if err != nil {
        log.Fatal(err)
    }

    cmd.Start()

    reader := bufio.NewReader(stdout)
	foo := &Foo{reader: stdout, writer: writer}

	wg := sync.WaitGroup{}
    wg.Add(1)
    go func() {
        defer wg.Done()
        if err := inputReader(os.Stdin, foo); err != nil {
            log.Println("input error:", err)
        }
    }()

	var cmdData Commands
	joinleave, err := disgohook.NewWebhookClientByToken(nil, log, "862747269722800188/5Q1JIPOmFWEYU420QM2CQiR7UtdbKly1iYiC5kA7JrTWOwHq0QFNWjSIKtzfrWXWFwoo")
	if err != nil {
		log.Errorf("Failed creating Webhook: %s", err)
		return
	}

	messages, err := disgohook.NewWebhookClientByToken(nil, log, "862748518557286401/t2oAUupmhMb8XmEfqR8hQSe9pKrOQvhS_NvDCArDfBGP2tmv_egqeTIWpTq5YBI6fx5X")
	if err != nil {
		log.Errorf("Failed creating Webhook: %s", err)
		return
	}

	// moderation, err := disgohook.NewWebhookClientByToken(nil, log, "862749070937686046/STAMzUzUJNMNTkC9O0BLt-n0ot7-M9xcFoeq-phc_msnzj6AFWQ0-0lRZbrkYHGxiMca")
	// if err != nil {
	// 	log.Errorf("Failed creating Webhook: %s", err)
	// 	return
	// }

	vehicle_log, err := disgohook.NewWebhookClientByToken(nil, log, "862749505220247552/TtNyRQRxnWCVCTR2N86FkAHF1l1g7aFJE7r0bJS3WzeT9H7ig8yuZWbfkOswa5a5wrtd")
	if err != nil {
		log.Errorf("Failed creating Webhook: %s", err)
		return
	}

	for {
		line, _, _ := reader.ReadLine()
			
		utilities.WriteLine(string(line))
		
		if strings.HasPrefix(string(line), "[API]") {
			re := regexp.MustCompile(`({)(.*)`)
			redata := re.FindStringSubmatch(string(line))
			if err := json.Unmarshal([]byte(redata[0]), &cmdData); err != nil {
				log.Errorln("Error decoding JSON.", err)
			} else {
				commandMap := make(map[string] func(cmdData Commands))
				commandMap["user_join"] = func(cmdData Commands) {
					_, err = joinleave.SendMessage(api.NewWebhookMessageCreateBuilder().
						SetContent(cmdData.Client.Name + " " + cmdData.Data).
						Build(),
					)
				}

				commandMap["user_message"] = func(cmdData Commands) {
					messages.EditWebhook(api.WebhookUpdate{Name: &cmdData.Client.Name})
					_, err = messages.SendMessage(api.NewWebhookMessageCreateBuilder().
						SetContent(cmdData.Data).
						Build(),
					)
				}

				commandMap["mod_log"] = func(cmdData Commands) {
					// _, err = moderation.SendMessage(api.NewWebhookMessageCreateBuilder().
					// 	SetContent("").
					// 	Build(),
					// )
				}

				commandMap["vehicle_log"] = func(cmdData Commands) {
					_, err = vehicle_log.SendMessage(api.NewWebhookMessageCreateBuilder().
						SetContent(cmdData.Client.Name + " " + cmdData.Data).
						Build(),
					)
				}

				commandMap[cmdData.Type](cmdData)
			}
		}
	}

	wg.Wait()
}