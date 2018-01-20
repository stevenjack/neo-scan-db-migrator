package main

import (
	"log"
	"net"
	"os"
	"os/exec"
	"strings"

	"github.com/vidsy/backoff"
)

func main() {
	bp := backoff.Policy{
		Intervals: []int{0, 500, 1000, 2000, 4000, 8000},
		LogPrefix: "[neo-scan-db-migrator]",
	}

	log.SetPrefix("[neo-scan-db-migrator] ")

	checkConnectkon := func() bool {
		conn, err := net.Dial("tcp", os.Getenv("POSTGRESS_HOST"))
		if err != nil {
			return false
		}

		_ = conn.Close()
		return true
	}

	ok := bp.Perform(checkConnectkon)
	if !ok {
		log.Fatal("Unable to connect to Postgress")
	}

	commandGroups := strings.Split(os.Getenv("SUCCESS_COMMANDS"), "&&")
	for _, commands := range commandGroups {
		log.Printf("Running command: '%s'", strings.TrimSpace(commands))
		commandParts := strings.Split(strings.TrimSpace(commands), " ")
		cmd := exec.Command(commandParts[0], commandParts[1:len(commandParts)]...)
		output, err := cmd.Output()

		if err != nil {
			log.Printf("Command finished with error: %s \n%s", err, output)
		} else {
			log.Printf("Command successfully finished:\n%s", output)
		}
	}
}
