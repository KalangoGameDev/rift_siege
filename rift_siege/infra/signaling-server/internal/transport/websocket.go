package transport

import (
	"rift-siege/infra/signaling-server/internal/signaling"
	"log"
	"net/http"
	"os"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize: 1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

func HandleWebSocket(hub *signaling.Hub, w http.ResponseWriter, r *http.Request) {
	serverSecret := os.Getenv("PSK")
	if serverSecret != "" {
		clientKey := r.URL.Query().Get("key")
		if clientKey != serverSecret {
			log.Printf("Authentication failed. Invalid key: %s", clientKey)
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}
	}

	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println("Upgrade error:", err)
		return
	}

	client := &signaling.Client{
		Hub: hub,
		Conn: conn,
		Send: make(chan signaling.Message, 256),
	}

	client.Hub.Register <- client

	go client.WritePump()
	go client.ReadPump()
}

