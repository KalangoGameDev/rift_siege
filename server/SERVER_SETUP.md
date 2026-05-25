# Server Configuration Guide for Coturn & Signaling

**Role:** Infrastructure Administrator / DevOps AI
**Target System:** `niflheim` (173.212.207.80)
**Objective:** Prepare the server to host the Game Signaling Server and the Coturn (TURN) Server.

## 1. Directory Structure
Ensure the following directories exist on the host machine. The Gitea Runner will deploy configuration files into these folders.

```bash
mkdir -p /home/nilbyte/infra/apps/coop-server
mkdir -p /home/nilbyte/infra/apps/coturn
```

## 2. Firewall Rules (Critical)
The TURN server requires specific ports to be open for relaying traffic. Without this, external players cannot connect.

**Allow Inbound Protocol/Ports:**
*   **3478:** TCP & UDP (STUN/TURN Signaling)
*   **5349:** TCP & UDP (TLS - Optional but recommended)
*   **49152 - 65535:** UDP (Relay Range - Required for data transfer)
*   **8080:** TCP (Signaling Server WebSocket)

**UFW Commands (Example):**
```bash
sudo ufw allow 8080/tcp comment 'Game Signaling'
sudo ufw allow 3478/tcp comment 'TURN Signaling TCP'
sudo ufw allow 3478/udp comment 'TURN Signaling UDP'
sudo ufw allow 49152:65535/udp comment 'TURN Relay Range'
sudo ufw reload
```

## 3. Docker Network (Optional)
If services need to talk to each other directly (mostly for monitoring), ensure a shared network exists, though `host` mode is used for Coturn.

```bash
docker network create signaling_net || true
```

## 4. Verification
After deployment, verify services are running:
```bash
docker ps | grep -E "coturn|signaling"
# Should show 'coturn-server' and 'rift-siege-signaling'
```
