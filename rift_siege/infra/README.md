# Infraestrutura do Rift Siege

Este diretório contém a infraestrutura de multiplayer usada pelo cliente Godot:

- `signaling-server/`: servidor WebSocket para troca de SDP/ICE.
- `apps/coturn/`: configuração do coturn para atravessar NAT.
- `.gitea/workflows/`: pipeline de build e deploy.

## Execução local

1. Suba o servidor de sinalização:
   ```bash
   cd rift_siege/infra/signaling-server
   go run cmd/server/main.go
   ```
2. Suba o TURN:
   ```bash
   cd rift_siege/infra/apps/coturn
   docker compose up -d
   ```

