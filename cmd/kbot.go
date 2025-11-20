/*
Copyright © 2025 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"fmt"
	"log"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/spf13/cobra"
	"gopkg.in/telebot.v4"
)

var (
	TeleToken = os.Getenv("TELE_TOKEN")
)

const (
	stateNone       = ""
	stateBackQAsked = "back_question_asked"
)

var (
	// зберігаємо стани по chat ID
	chatStates = make(map[int64]string)
	stateMu    sync.Mutex
)

func setState(chatID int64, state string) {
	stateMu.Lock()
	defer stateMu.Unlock()
	chatStates[chatID] = state
}

func getState(chatID int64) string {
	stateMu.Lock()
	defer stateMu.Unlock()
	return chatStates[chatID]
}

// kbotCmd represents the kbot command
var kbotCmd = &cobra.Command{
	Use:     "kbot",
	Aliases: []string{"start"},
	Short:   "A brief description of your command",
	Long: `A longer description that spans multiple lines and likely contains examples
and usage of using your command. For example:

Cobra is a CLI library for Go that empowers applications.
This application is a tool to generate the needed files
to quickly create a Cobra application.`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("kbot %s started\n", appVersion)

		kbot, err := telebot.NewBot(telebot.Settings{
			URL:    "",
			Token:  TeleToken,
			Poller: &telebot.LongPoller{Timeout: 10 * time.Second},
		})
		if err != nil {
			log.Fatalf("Failed to create bot. Please check TeleToken: %s", err)
			return
		}

		kbot.Handle(telebot.OnText, func(c telebot.Context) error {
			text := strings.TrimSpace(c.Text())
			lower := strings.ToLower(text)
			chatID := c.Chat().ID

			log.Printf("Received message from chat %d: %s", chatID, text)

			currentState := getState(chatID)

			// 1. Старт діалогу
			if currentState == stateNone &&
				(lower == "hello" || lower == "/start") {

				setState(chatID, stateBackQAsked)
				return c.Send("Hello, Elizabeth! Have you zrobyla vpravy na spynu? Yes/No")
			}

			// 2. Ми вже задали питання й чекаємо Yes/No
			if currentState == stateBackQAsked {
				if lower == "yes" || lower == "y" {
					setState(chatID, stateNone)
					return c.Send("Great! +1 day of back exercises! 🔥 Kseniia is happy 🥰")
				}
				if lower == "no" || lower == "n" {
					setState(chatID, stateNone)
					return c.Send("Kseniia is sad. Come back tomorrow, Elizabeth. We will talk again.")
				}

				// некоректна відповідь – просимо конкретно Yes/No, не змінюючи стан
				return c.Send("Please answer only Yes or No 🙂")
			}

			// 3. Будь-який інший текст поза діалогом
			return c.Send("Type 'hello' or '/start' to begin our little back-exercise ritual 😉")
		})

		kbot.Start()
	},
}

func init() {
	rootCmd.AddCommand(kbotCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// kbotCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// kbotCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}
