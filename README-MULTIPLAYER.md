# Multiplayer & Single-Player Guide

This guide explains how the game's multiplayer and single-player modes work.

## Game Modes

### Single-Player Mode
- Click "Play" from the main menu
- No server connection required
- Play solo through the levels
- All game mechanics work normally

### Multiplayer Mode
- Click "Multiplayer" from the main menu
- Requires Nakama server running (see README-DOCKER.md)
- Two players can play together in real-time
- See each other's movements, animations, and actions

## How It Works

### Single-Player Flow
1. Main Menu → Click "Play"
2. `GameManager.match_id` is cleared (set to empty string)
3. Level loads without multiplayer sync
4. Player plays alone

### Multiplayer Flow
1. Main Menu → Click "Multiplayer"
2. Login screen → Enter email/password
3. Lobby screen → Create or Join match
4. Level loads with multiplayer sync enabled
5. Remote player spawns when second player joins

## Technical Details

### Player Synchronization
The local player sends position updates 20 times per second (every 0.05s):
- Position (x, y)
- Velocity (vx, vy)
- Sprite flip direction
- Current animation

The remote player receives these updates and mirrors the local player's movements.

### Match State Filtering
- Each player only processes match state from OTHER players
- Your own state updates are ignored to prevent feedback loops
- Uses session username comparison to filter messages

### Remote Player Spawning
- Remote player spawns automatically when a second player joins the match
- Spawns at `spawn_pos + Vector2(50, 0)` (slightly offset from local player)
- Added to "remote_player" group for easy lookup
- Removed when the other player leaves

## Testing Multiplayer Locally

### Method 1: Two Godot Instances
1. Start Docker: `docker-compose up`
2. Open project in Godot Editor (Player 1)
3. Export the game to a build folder
4. Run the exported game (Player 2)
5. Both players log in with different accounts
6. Player 1 creates a match, shares the Match ID
7. Player 2 joins using that Match ID

### Method 2: Two Computers (Same Network)
1. Start Docker on Computer 1
2. Find Computer 1's local IP: `ipconfig` (e.g., 192.168.1.100)
3. On Computer 2, update `GameManager.gd`:
   ```gdscript
   client = Nakama.create_client(
       "defaultkey",
       "192.168.1.100",  # Computer 1's IP
       7350,
       "http"
   )
   ```
4. Both players log in and join the same match

## Common Issues & Solutions

### Issue: Remote player doesn't appear
**Cause**: Second player hasn't joined yet, or match presence event not received

**Solution**:
- Ensure both players are in the same match (same Match ID)
- Check console for "👥 Match presence event" messages
- Verify Docker is running: `docker-compose ps`

### Issue: Remote player is jittery/laggy
**Cause**: Network latency or sync rate too low

**Solution**:
- Increase `sync_interval` in player.gd (currently 0.05s)
- Check network connection quality
- Ensure both players are on same local network for testing

### Issue: Single-player mode tries to connect to server
**Cause**: `GameManager.match_id` not cleared

**Solution**: This is now fixed - "Play" button clears match_id automatically

### Issue: Players see their own ghost
**Cause**: Not filtering own match state messages

**Solution**: This is now fixed - username comparison filters own messages

### Issue: Remote player doesn't move
**Cause**: Not in "remote_player" group or sync not enabled

**Solution**:
- Check RemotePlayer.tscn has `is_local_player = false`
- Verify remote player is added to "remote_player" group
- Check console for "🌐 Multiplayer sync enabled" message

## Code Architecture

### GameManager (Autoload)
- Manages Nakama client, session, socket
- Stores current `match_id`
- Handles authentication and match creation/joining

### Player Script
- `is_local_player` flag determines behavior
- Local player: Processes input, sends state
- Remote player: Receives state, updates visuals
- Filters own messages using session username

### Level Script
- Detects multiplayer mode by checking `GameManager.match_id`
- Spawns remote player when match presence detected
- Removes remote player when other player leaves

## Network Protocol

### Op Code 1: Player State
```json
{
  "x": 150.5,
  "y": 300.0,
  "vx": 250.0,
  "vy": 0.0,
  "flip": false,
  "anim": "run"
}
```

Sent via: `GameManager.socket.send_match_state_async(match_id, 1, JSON.stringify(state))`

Received via: `GameManager.socket.received_match_state` signal

## Performance Considerations

### Bandwidth Usage
- ~20 messages/second per player
- ~200 bytes per message
- Total: ~4 KB/s per player (very low)

### CPU Usage
- Minimal - just JSON parsing and position updates
- No physics simulation for remote player
- Animations driven by received state

## Future Enhancements

Potential improvements for multiplayer:
1. **Interpolation**: Smooth remote player movement between updates
2. **Prediction**: Predict remote player position to reduce perceived lag
3. **Combat sync**: Synchronize attacks and damage
4. **Chat system**: Add text chat using Nakama channels
5. **Matchmaking**: Use Nakama matchmaker instead of manual Match IDs
6. **Spectator mode**: Allow watching matches without playing
7. **Replay system**: Record and playback matches

## Debugging Tips

### Enable Verbose Logging
Add print statements to track multiplayer events:

```gdscript
# In player.gd _send_state()
print("📤 Sending state: ", state)

# In player.gd _on_match_state()
print("📥 Received state from: ", match_state.username)
print("    Data: ", data)
```

### Check Match State
In Nakama Console (http://localhost:7351):
1. Go to "Matches" tab
2. Find your match by ID
3. View connected players
4. Monitor match state messages

### Network Monitor
Use Godot's built-in profiler:
1. Debug → Profiler
2. Network tab
3. Monitor bytes sent/received

## Security Notes

**Current Setup (Development Only)**:
- Default server key: "defaultkey"
- No encryption (HTTP, not HTTPS)
- No input validation
- No anti-cheat

**For Production**:
- Change server key in docker-compose.yml
- Enable HTTPS/WSS
- Validate all client inputs on server
- Implement server-authoritative game logic
- Add anti-cheat measures

## Support

If you encounter issues:
1. Check Docker is running: `docker-compose ps`
2. Verify Nakama is accessible: http://localhost:7351
3. Check Godot console for error messages
4. Review this guide's troubleshooting section
5. Check Nakama logs: `docker-compose logs nakama`

Happy gaming! 🎮
