# Rift Siege Signaling Server

Servidor de sinalização WebSocket em Go para estabelecer conexões WebRTC entre clientes Godot.

## Execução local

```bash
go mod tidy
go run cmd/server/main.go
```

O servidor sobe em `ws://localhost:8080/ws`.

## Protocolo

Mensagens JSON suportadas:

- `id`
- `peers`
- `offer`
- `answer`
- `candidate`
