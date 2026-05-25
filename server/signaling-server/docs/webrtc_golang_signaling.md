# Implementação de Servidor de Sinalização (Signaling Server) em Golang

Para que dois clientes WebRTC (Peer-to-Peer) possam se comunicar, eles precisam primeiro trocar informações de conexão (SDP - Session Description Protocol e ICE Candidates). Como eles ainda não têm uma conexão direta, essa troca é feita intermediada por um servidor público conhecido como **Signaling Server**.

Abaixo segue um guia de como implementar um servidor de sinalização simples usando **Golang** e **WebSockets**.

## Pré-requisitos

1. Golang instalado.
2. Biblioteca `gorilla/websocket`:
   ```bash
   go get github.com/gorilla/websocket
   ```

## Estrutura do Servidor

O servidor precisa:

1. Aceitar conexões WebSocket.
2. Manter registro dos clientes conectados (peers).
3. Repassar mensagens de um cliente para outro (Offers, Answers, ICE Candidates).

### Código Exemplo

O código foi organizado em `cmd/server`, `internal/signaling` e `internal/transport`.

## Como Usar no Godot

No lado do Godot (Client), você precisará:

1. Conectar ao WebSocket: `ws://localhost:8080/ws`.
2. Ao conectar, receber seu ID (`type: "id"`).
3. Para conectar com outro peer:
   - Criar `WebRTCPeerConnection`.
   - Criar Oferta (`create_offer`).
   - Receber a oferta gerada e enviá-la via WebSocket com `type: "offer"`.
4. Ao receber `type: "offer"`:
   - Setar `set_remote_description`.
   - Criar Resposta (`create_answer`).
   - Enviar resposta via WS com `type: "answer"`.
5. Ao receber `type: "candidate"`:
   - Adicionar `add_ice_candidate`.

Certifique-se de configurar o `WebRTCMultiplayerPeer` corretamente para usar o modo Mesh (todos conecta com todos) ou Cliente-Servidor.

