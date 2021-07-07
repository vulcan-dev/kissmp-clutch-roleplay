package main

import (
	"encoding/json"
	"net/http"
	"os"
	"strconv"

	"github.com/gorilla/mux"
)

type SServer struct {}

var command = SCommands{}

func (server *SServer) handler_discord(w http.ResponseWriter, r* http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
    w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
    w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	if r.Method == "POST" {
		decoder := json.NewDecoder(r.Body)
		
		/* Map all the API Commands */
		var data SCommands
		if err := decoder.Decode(&data); err != nil {
			log.Errorln("Error decoding JSON.", err)
		} else {
			if data.Auth == "abc" {
				log.Infoln(data)
				commandMap := map[string] func(data SCommands) {
					"user_kick": command.user_kick,
					"user_ban": command.user_ban,
					"user_unban": command.user_unban,
					"user_warn": command.user_warn,
					"user_report": command.user_report,
					"user_joined": command.user_user_joined,
					"user_left": command.user_user_left,
					"user_muted": command.user_muted,
					"user_unmuted": command.user_unmuted,
					"user_chat": command.user_chat,
					"user_vehicle_spawn": command.user_vehicle_spawn,
				}

				commandMap[data.Command](data)
			} else {
				log.Warnln("Someone tried sending data with an invalid authkey.", data.Auth)
			}
		}
	}
}

func (server *SServer) new(address string, port int) {
	// file, err := ioutil.ReadFile("./settings.json")
    // if err != nil {
	// 	log.Errorln("Failed reading file.", err)
    // }

	// var data SCommands
    // if err = json.Unmarshal(file, &data); err != nil {
    //     log.Errorln("Failed unmarshalling channels:", err)
    // }

    mux := mux.NewRouter()

	mux.HandleFunc("/api", server.handler_discord).Methods("POST")

	log.Infoln("API: Starting server ", "http://" + address + ":" + strconv.Itoa(port))
	if err := http.ListenAndServe(address + ":" + strconv.Itoa(port), mux); err != nil {
		log.Errorln(err)
		os.Exit(1)
	}
}