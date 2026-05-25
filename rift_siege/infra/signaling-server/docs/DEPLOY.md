# Deploy do Signaling Server

Este documento descreve a publicação do servidor de sinalização em contêiner.

## Build

```bash
cd rift_siege/infra/signaling-server
docker build -t rift-siege-signaling .
```

## Run

```bash
docker run --rm -p 8080:8080 -e PSK=secret123 rift-siege-signaling
```

