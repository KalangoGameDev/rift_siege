package signaling

import (
	"encoding/json"
	"log"
	"sync"
)

type Hub struct {
	clients map[int]*Client
	Broadcast chan Message
	Register chan *Client
	Unregister chan *Client
	nextID int
	mu sync.Mutex
}

func NewHub() *Hub {
	return &Hub{
		Broadcast: make(chan Message),
		Register: make(chan *Client),
		Unregister: make(chan *Client),
		clients: make(map[int]*Client),
		nextID: 1,
	}
}

func (h *Hub) Run() {
	for {
		select {
		case client := <-h.Register:
			h.mu.Lock()
			client.ID = h.nextID
			h.nextID++
			h.clients[client.ID] = client
			h.mu.Unlock()

			log.Printf("Client connected: %d", client.ID)

			idBytes, _ := json.Marshal(client.ID)
			msg := Message{
				Type: "id",
				Data: json.RawMessage(idBytes),
			}
			client.Send <- msg
			h.broadcastUserList()

		case client := <-h.Unregister:
			h.mu.Lock()
			if _, ok := h.clients[client.ID]; ok {
				delete(h.clients, client.ID)
				close(client.Send)
				log.Printf("Client disconnected: %d", client.ID)
			}
			h.mu.Unlock()
			h.broadcastUserList()

		case msg := <-h.Broadcast:
			log.Printf("Trace: Routing message type='%s' from %d to target %d", msg.Type, msg.Sender, msg.Target)
			h.routeMessage(msg)
		}
	}
}

func (h *Hub) broadcastUserList() {
	h.mu.Lock()
	defer h.mu.Unlock()

	peerIDs := make([]int, 0, len(h.clients))
	for id := range h.clients {
		peerIDs = append(peerIDs, id)
	}

	dataBytes, _ := json.Marshal(peerIDs)
	msg := Message{
		Type: "peers",
		Data: json.RawMessage(dataBytes),
	}

	for _, client := range h.clients {
		select {
		case client.Send <- msg:
		default:
			close(client.Send)
			delete(h.clients, client.ID)
		}
	}
}

func (h *Hub) routeMessage(msg Message) {
	h.mu.Lock()
	defer h.mu.Unlock()

	if msg.Target > 0 {
		if target, ok := h.clients[msg.Target]; ok {
			select {
			case target.Send <- msg:
			default:
				close(target.Send)
				delete(h.clients, target.ID)
			}
		}
	} else {
		for id, client := range h.clients {
			if id == msg.Sender {
				continue
			}
			select {
			case client.Send <- msg:
			default:
				close(client.Send)
				delete(h.clients, id)
			}
		}
	}
}

