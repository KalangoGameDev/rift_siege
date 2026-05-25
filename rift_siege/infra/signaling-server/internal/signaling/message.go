package signaling

import (
	"encoding/json"
	"fmt"
)

type Message struct {
	Type   string          `json:"type"`
	Data   json.RawMessage `json:"data,omitempty"`
	Target int             `json:"target,omitempty"`
	Sender int             `json:"sender,omitempty"`
}

func IDToJSON(id int) json.RawMessage {
	return json.RawMessage([]byte(fmt.Sprintf("%d", id)))
}

