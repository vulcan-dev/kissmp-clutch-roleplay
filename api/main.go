package main

/*
 Oi cunt read me right now!
 So... when you wake up do what u do and then code

 What you need to do is:
	create an addBan function and check if it's mssql or json
	send the user through that function
	if it's json then ban and kick the fucker from the server
	if it's mssql then figure out if you can disconnect the user via sendLua. before that though make sure the fucker gets banned so user is valid
*/

/*
	Hello again, this is a reminder u cunt
	So.. Add an API method to retrieve all users in-game so I can add it to my server list
*/
import (
	"flag"
	"os"
	"os/exec"
	"os/signal"
	"syscall"

	nested "github.com/antonfisher/nested-logrus-formatter"
	"github.com/sirupsen/logrus"
)

var (
	log = InitializeLogger()
	// db SDatabase
	bot SBot
	canUseDB bool
)

func main() {
	cmd := exec.Command("cmd", "/c", "cls") //Windows example, its tested 
	cmd.Stdout = os.Stdout
	cmd.Run()
	
	SetupCloseHandler()

	// db_server := flag.String("db_server", "", "the database server")
	// db_user := flag.String("db_user", "", "the database user")
	// db_password := flag.String("db_password", "", "the database password")
	// db_port := flag.Int("db_port", 1433, "the database port")

	address := flag.String("address", "127.0.0.1", "address to start server")
	port := flag.Int("port", 30205, "port for the server")
	//VULCAN_BOT := flag.String("VULCAN_BOT", "", "Discord token to start the bot")
	flag.Parse()

	// db.Server = *db_server
	// db.User = *db_user
	// db.Password = *db_password
	// db.Port = *db_port
	
	server := SServer{}

	canUseDB = false

	// _, err := db.new(); if err != nil {
	// 	log.Errorln("[DB] Failed connecting to Database. ", err)
	// 	canUseDB = false
	// }

	bot.VULCAN_BOT = "Nzk1NDU0MTMxNTczNjIwNzY2.X_JmYw.DOglaoxoE8nr2GtpA0iCuiGFXXw"
	// Haha, I changed it.
	bot.new()
	server.new(*address, *port)

	// defer db.Database.Close()
}

func SetupCloseHandler() {
	c := make(chan os.Signal)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-c
		log.Infoln("Shutting down API")
		os.Exit(0)
	}()
}

func InitializeLogger() *logrus.Logger {
	log := logrus.New()
	log.SetFormatter(&nested.Formatter{
		HideKeys:    false,
		TimestampFormat: "2006-01-02 15:04:05",
		TrimMessages: true,
	})

	return log
}
