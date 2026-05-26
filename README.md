# Rift Siege

Repositório do jogo `Rift Siege`, organizado de forma horizontal:

- `client/`: cliente Godot com a lógica, cenas, sprites e assets.
- `server/`: servidor de sinalização, TURN e automação de deploy.

## Estrutura

- [`docker-compose.yml`](/home/notilton/Workspace/kalango-gamedev/rift_siege/docker-compose.yml): stack local de multiplayer.
- [`client/`](/home/notilton/Workspace/kalango-gamedev/rift_siege/client)
- [`server/`](/home/notilton/Workspace/kalango-gamedev/rift_siege/server)
- [`.gitea/workflows/`](/home/notilton/Workspace/kalango-gamedev/rift_siege/.gitea/workflows)

## Multiplayer

O multiplayer cooperativo deste projeto não usa um servidor de jogo autoritário para simulação contínua.
O fluxo atual é:

1. O `client` abre uma conexão WebSocket com o `signaling server`.
2. O `signaling server` atribui um `id` para cada cliente e distribui a lista de `peers`.
3. Os clients criam conexões `WebRTC` diretas entre si, trocando `offer`, `answer` e `candidate` pelo `signaling server`.
4. O `coturn` entra como servidor `TURN` para atravessar NAT/firewall quando a conexão direta não fecha.
5. Depois que o `WebRTC` sobe, o tráfego de jogo vai direto entre os peers. O servidor de sinalização não carrega gameplay.

```text
                         ┌──────────────────────────┐
                         │   Signaling Server       │
                         │   WebSocket :8080        │
                         │  id / peers / SDP / ICE  │
                         └───────────┬──────────────┘
                                     │
                 conecta via WS      │      conecta via WS
               /ws?key=PSK           │        /ws?key=PSK
                                     │
          ┌──────────────────────────┴──────────────────────────┐
          │                                                     │
    ┌─────▼─────┐                                         ┌─────▼─────┐
    │ Client A  │                                         │ Client B  │
    │   Godot   │                                         │   Godot   │
    └─────┬─────┘                                         └─────┬─────┘
          │                                                     │
          │          1. trocam offer / answer / candidate       │
          │          2. o signaling só repassa mensagens        │
          │                                                     │
          └───────────────────┬─────────────────────────────────┘
                              │
                              ▼
                 ┌──────────────────────────────┐
                 │      WebRTC P2P direto       │
                 │  gameplay / estado / tiros   │
                 └───────────┬───────────────────┘
                             │
                    se NAT/firewall atrapalhar
                             │
                             ▼
                 ┌──────────────────────────────┐
                 │           Coturn             │
                 │        TURN / STUN :3478     │
                 │      relay fallback NAT      │
                 └──────────────────────────────┘
```

### O que cada peça faz

- `client`: abre o lobby, conecta no signaling, negocia a sessão WebRTC e depois troca dados de jogo com os outros peers.
- `signaling server`: só coordena a descoberta. Ele registra quem entrou, manda a lista de peers e roteia mensagens de sinalização.
- `coturn`: fornece relay quando a conexão P2P direta não consegue atravessar NAT, ISP ou firewall.
- `coop server`: no estado atual do código, não existe um servidor de gameplay separado. O nome aparece só em alguns caminhos de deploy, mas a autoridade do jogo não está centralizada em um backend de simulação.

### Fluxo resumido

```text
client A -> signaling server: connect WebSocket
signaling server -> client A: id + peers
client A -> signaling server: offer/answer/candidate para client B
client A <-> coturn: STUN/TURN quando necessário
client A <-> client B: canal WebRTC para gameplay
```

## Desenvolvimento

1. Suba a infraestrutura de multiplayer:
   ```bash
   docker compose up -d
   ```
2. Abra `client/` no Godot e execute o projeto normalmente.
3. Copie [.env.example](/home/notilton/Workspace/kalango-gamedev/rift_siege/.env.example) para `.env` e ajuste `PSK`, `ADVERTISED_IP`, `TURN_EXTERNAL_IP`, `TURN_USER` e `TURN_PASSWORD`.
