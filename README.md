# Rift Siege

Repositório do jogo `Rift Siege`, organizado de forma horizontal:

- `client/`: cliente Godot com a lógica, cenas, sprites e assets.
- `server/`: servidor de sinalização, TURN e automação de deploy.

## Estrutura

- [`docker-compose.yml`](/home/notilton/Workspace/kalango-gamedev/rift_siege/docker-compose.yml): stack local de multiplayer.
- [`client/`](/home/notilton/Workspace/kalango-gamedev/rift_siege/client)
- [`server/`](/home/notilton/Workspace/kalango-gamedev/rift_siege/server)
- [`.gitea/workflows/`](/home/notilton/Workspace/kalango-gamedev/rift_siege/.gitea/workflows)

## Desenvolvimento

1. Suba a infraestrutura de multiplayer:
   ```bash
   docker compose up -d
   ```
2. Abra `client/` no Godot e execute o projeto normalmente.
3. Copie [.env.example](/home/notilton/Workspace/kalango-gamedev/rift_siege/.env.example) para `.env` e ajuste `PSK`, `ADVERTISED_IP`, `TURN_EXTERNAL_IP`, `TURN_USER` e `TURN_PASSWORD`.
