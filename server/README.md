# Infraestrutura do Rift Siege

Este diretório contém a infraestrutura de multiplayer usada pelo cliente Godot:

- `signaling-server/`: servidor WebSocket para troca de SDP/ICE.
- `apps/coturn/`: configuração do coturn para atravessar NAT.
- `../.gitea/workflows/`: pipeline de build e deploy.

## Execução local

1. Copie [.env.example](/home/notilton/Workspace/kalango-gamedev/rift_siege/.env.example) para `.env` e ajuste os valores se necessário.
2. Suba a stack pela raiz do repositório:
   ```bash
   docker compose up -d
   ```
3. Ou rode o servidor de sinalização isolado:
   ```bash
   cd server/signaling-server
   go run cmd/server/main.go
   ```
4. Ou rode o TURN isolado:
   ```bash
   cd server/apps/coturn
   docker compose up -d
   ```
