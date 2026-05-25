package main

import (
	"io"
	"log"
	"net"
	"net/http"
	"os"
	"strings"
	"time"

	"rift-siege/infra/signaling-server/internal/signaling"
	"rift-siege/infra/signaling-server/internal/transport"
)

func main() {
	hub := signaling.NewHub()
	go hub.Run()

	http.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {
		transport.HandleWebSocket(hub, w, r)
	})

	ipStr := getPublicIP()
	if ipStr == "" {
		ipStr = getOutboundIP().String()
	}

	if advertised := os.Getenv("ADVERTISED_IP"); advertised != "" {
		ipStr = advertised
	}

	localIP := getOutboundIP().String()
	psk := os.Getenv("PSK")

	log.Printf("Server started on 0.0.0.0:8080")
	log.Println("---------------------------------------------------------")
	log.Printf("External Connection: ws://%s:8080/ws?key=%s", ipStr, psk)
	if ipStr != localIP {
		log.Printf("Local LAN Connection:  ws://%s:8080/ws?key=%s", localIP, psk)
	}
	log.Printf("Localhost Connection:  ws://localhost:8080/ws?key=%s", psk)
	log.Println("---------------------------------------------------------")

	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}

func getPublicIP() string {
	client := http.Client{
		Timeout: 5 * time.Second,
	}
	resp, err := client.Get("https://api.ipify.org?format=text")
	if err != nil {
		return ""
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return ""
	}

	return strings.TrimSpace(string(body))
}

func getOutboundIP() net.IP {
	conn, err := net.Dial("udp", "8.8.8.8:80")
	if err != nil {
		return net.IPv4(127, 0, 0, 1)
	}
	defer conn.Close()

	localAddr := conn.LocalAddr().(*net.UDPAddr)

	return localAddr.IP
}

