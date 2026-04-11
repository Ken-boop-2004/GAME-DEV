# Docker Setup for Godot Nakama Multiplayer Game

This guide explains how to run your Godot multiplayer game with Nakama server using Docker Desktop (Free).

## What's Included

Your game uses **Nakama** - an open-source multiplayer game server that handles:
- User authentication (email/password)
- Real-time multiplayer matches
- Matchmaking and lobbies
- Player synchronization

The Docker setup includes:
1. **PostgreSQL Database** - Stores user accounts, match data, etc.
2. **Nakama Server** - The game server your Godot client connects to

## Prerequisites

- **Docker Desktop** (Free version) installed and running
- Windows with WSL2 enabled (Docker Desktop handles this automatically)
- At least 2GB of free RAM
- Ports 7350, 7351, 5432 available (not used by other applications)

## Quick Start

### 1. Start the Servers

Open a terminal in your project folder and run:

```bash
docker-compose up
```

**First time setup takes 2-3 minutes** as Docker downloads the required images (~500MB total).

You'll see logs indicating the servers are ready:
```
nakama    | {"level":"info","ts":"...","msg":"Startup done"}
postgres  | database system is ready to accept connections
```

### 2. Verify It's Running

Open your browser and go to:
- **Nakama Console**: http://localhost:7351
  - Username: `admin`
  - Password: `password`

### 3. Run Your Godot Game

1. Open your project in Godot Engine
2. Press F5 or click "Run Project"
3. The game will connect to `127.0.0.1:7350` (your local Nakama server)
4. Create an account and log in!

### 4. Stop the Servers

Press `Ctrl+C` in the terminal, then run:

```bash
docker-compose down
```

## Important Ports

| Port | Service | Purpose |
|------|---------|---------|
| 7350 | Nakama HTTP | Your Godot game connects here |
| 7351 | Nakama Console | Web admin interface |
| 7349 | Nakama gRPC | Advanced API (not used by your game) |
| 5432 | PostgreSQL | Database (internal use) |

## Common Commands

### Start in Background (Detached Mode)
```bash
docker-compose up -d
```

### View Logs
```bash
docker-compose logs -f
```

### Stop Everything
```bash
docker-compose down
```

### Reset Database (Fresh Start)
```bash
docker-compose down -v
docker-compose up
```
**Warning**: This deletes all user accounts and match data!

## Troubleshooting

### "Port already in use"
Another application is using port 7350, 7351, or 5432. 

**Solution**: Stop the conflicting application or modify `docker-compose.yml` to use different ports:
```yaml
ports:
  - "8350:7350"  # Change 7350 to 8350
```
Then update `GameManager.gd` to use the new port.

### "Cannot connect to Docker daemon"
Docker Desktop is not running.

**Solution**: Start Docker Desktop from the Start menu.

### Game shows "Connection failed"
The Nakama server isn't ready yet.

**Solution**: Wait 30 seconds after running `docker-compose up`, then try again.

### "Database migration failed"
The database is corrupted or in a bad state.

**Solution**: Reset everything:
```bash
docker-compose down -v
docker-compose up
```

## Configuration Details

### Current Setup (GameManager.gd)
```gdscript
client = Nakama.create_client(
    "defaultkey",      # Server key (default for local dev)
    "127.0.0.1",       # Localhost
    7350,              # HTTP port
    "http"             # Protocol (use https in production)
)
```

### Session Expiry
Sessions last **2 hours** (7200 seconds) before requiring re-authentication. This is configured in `docker-compose.yml`:
```yaml
--session.token_expiry_sec 7200
```

### Data Persistence
User accounts and match data are stored in a Docker volume named `data`. This persists even when you stop the containers.

To completely wipe all data:
```bash
docker-compose down -v
```

## Testing Multiplayer

### Local Testing (Same Computer)
1. Start Docker: `docker-compose up`
2. Run your game in Godot (Player 1)
3. Export your game and run the exported version (Player 2)
4. Player 1 creates a match, shares the Match ID
5. Player 2 joins using that Match ID

### Network Testing (Different Computers)
1. Find your local IP: `ipconfig` (look for IPv4 Address, e.g., 192.168.1.100)
2. Update `GameManager.gd` on the second computer:
   ```gdscript
   "192.168.1.100",  # Replace with your IP
   ```
3. Ensure Windows Firewall allows port 7350
4. Both computers must be on the same network

## Production Deployment

**Important**: This setup is for LOCAL DEVELOPMENT ONLY!

For production (real players over the internet):
- Use a cloud hosting service (AWS, Google Cloud, DigitalOcean)
- Enable HTTPS/WSS encryption
- Change the default server key
- Use a managed PostgreSQL database
- Configure proper firewall rules

See: https://heroiclabs.com/docs/install-configuration/

## Resource Usage (Docker Desktop Free)

- **RAM**: ~300-500MB
- **CPU**: Minimal when idle, <10% during gameplay
- **Disk**: ~500MB for images, ~50MB for data
- **Network**: Local only (no internet required)

Docker Desktop Free is perfectly fine for development and local testing!

## Need Help?

- Nakama Documentation: https://heroiclabs.com/docs
- Nakama Community: https://forum.heroiclabs.com
- Docker Desktop Docs: https://docs.docker.com/desktop/

## Files in This Setup

- `docker-compose.yml` - Defines the services (Nakama + PostgreSQL)
- `README-DOCKER.md` - This file
- `GameManager.gd` - Your game's connection configuration
