package main

import (
	"bufio"
	"encoding/json"
	"os/exec"
	"regexp"
	"strings"

	"github.com/DisgoOrg/disgohook"
	"github.com/DisgoOrg/disgohook/api"
)

var (
	utilities Utilities
	log = utilities.InitializeLogger()
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

func main() {
	utilities.SetupCloseHandler()

    cmd := exec.Command("../server/clutch-roleplay.exe")
	cmd.Dir = "../server/"
    stdout, err := cmd.StdoutPipe()

    if err != nil {
        log.Fatal(err)
    }

    cmd.Start()

    buf := bufio.NewReader(stdout)

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
        line, _, _ := buf.ReadLine()
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
}