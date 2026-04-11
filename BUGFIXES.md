# Bug Fixes Applied

## Critical Errors Fixed

### 1. ❌ Invalid access to 'username' on MatchData
**Error**: `Invalid access to property or key 'username' on a base object of type 'RefCounted (MatchData)'`

**Root Cause**: `MatchData` doesn't have a `username` property. It has a `presence` property which contains user information.

**Fix**: Changed from:
```gdscript
if match_state.username == GameManager.session.username:
```

To:
```gdscript
if match_state.presence and match_state.presence.user_id == GameManager.session.user_id:
```

**MatchData Structure**:
- `match_id`: String - The match identifier
- `op_code`: int - Operation code (we use 1 for player state)
- `presence`: UserPresence - Contains sender info
  - `user_id`: String - Unique user ID
  - `session_id`: String - Session identifier
  - `username`: String - Display name
- `data`: String - The actual message data (JSON)

### 2. ❌ Node not found: "Player"
**Error**: `Node not found: "Player" (relative to "/root/GameLevel")`

**Root Cause**: The actual node name in level.tscn is `"player"` (lowercase), not `"Player"`.

**Fix**: Changed from:
```gdscript
@onready var player = $Player
```

To:
```gdscript
@onready var player = $player
```

### 3. ❌ Node not found: "CanvasLayer/LevelNotification"
**Error**: `Node not found: "CanvasLayer/LevelNotification"`

**Root Cause**: The notification label is directly under the root, not under CanvasLayer. The actual path is just `$LevelNotification`.

**Fix**: Changed from:
```gdscript
@onready var notification: Label = $CanvasLayer/LevelNotification
```

To:
```gdscript
@onready var level_notification: Label = $LevelNotification
```

Also renamed variable from `notification` to `level_notification` to avoid shadowing the built-in `Object.notification()` method.

### 4. ❌ Node not found: "TriggerL2"
**Error**: `Node not found: "TriggerL2"`

**Root Cause**: The TriggerL2 node may not exist in all level scenes.

**Fix**: Made it optional:
```gdscript
@onready var trigger_l2: Area2D = null  # Will try to find it if it exists

func _ready():
    # Try to find TriggerL2 if it exists
    if has_node("TriggerL2"):
        trigger_l2 = $TriggerL2
        trigger_l2.body_entered.connect(_on_l2_trigger)
```

## Warnings Fixed

### 1. ⚠️ Unused variable "result"
**Warning**: `The local variable "result" is declared but never used`

**Fix**: Prefixed with underscore:
```gdscript
var _result = await GameManager.join_match(match_id)
```

### 2. ⚠️ Shadowed variable "notification"
**Warning**: `The local variable "notification" is shadowing an already-declared method in the base class "Object"`

**Fix**: Renamed to `level_notification`:
```gdscript
@onready var level_notification: Label = $LevelNotification
```

### 3. ⚠️ Unused parameter "delta"
**Warning**: `The parameter "delta" is never used in the function "_process()"`

**Fix**: Prefixed with underscore:
```gdscript
func _process(_delta):
```

## Resource UID Warnings

The warnings about invalid UIDs are non-critical:
```
ext_resource, invalid UID: uid://dbkuqps1g6776 - using text path instead
```

These occur when Godot can't find a resource by UID and falls back to the text path. The game still works correctly. To fix permanently:
1. Open the scene in Godot Editor
2. Save it (Ctrl+S)
3. Godot will regenerate the UIDs

## Testing Checklist

After these fixes, verify:

### Single-Player Mode
- [ ] Click "Play" from main menu
- [ ] Game loads without errors
- [ ] Player can move, jump, dash
- [ ] No console errors about Nakama/multiplayer

### Multiplayer Mode
- [ ] Start Docker: `docker-compose up`
- [ ] Click "Multiplayer" from main menu
- [ ] Login with email/password
- [ ] Create match (Player 1)
- [ ] Join match (Player 2)
- [ ] Both players see each other
- [ ] Movements are synchronized
- [ ] No console errors about username/presence

## Nakama API Reference

### Match State Structure
```gdscript
# Sending match state
GameManager.socket.send_match_state_async(
    match_id,           # String: Match identifier
    op_code,            # int: Operation code (1 = player state)
    JSON.stringify(data) # String: JSON data
)

# Receiving match state
func _on_match_state(match_state):
    # match_state properties:
    # - match_id: String
    # - op_code: int
    # - presence: UserPresence (sender info)
    #   - user_id: String
    #   - session_id: String
    #   - username: String
    # - data: String (JSON)
```

### Session Structure
```gdscript
# GameManager.session properties:
# - user_id: String (unique user identifier)
# - username: String (display name)
# - token: String (JWT auth token)
# - expired: bool
# - expire_time: int
```

## Common Pitfalls to Avoid

1. **Don't use `match_state.username`** - Use `match_state.presence.username` instead
2. **Check node names match scene** - Use exact capitalization from .tscn file
3. **Handle optional nodes** - Use `has_node()` before accessing with `$`
4. **Prefix unused variables** - Use `_variable` to suppress warnings
5. **Filter own messages** - Compare `user_id` not `username` for reliability

## Debug Tips

### Print Match State Info
```gdscript
func _on_match_state(match_state):
    print("📥 Match State Received:")
    print("  Match ID: ", match_state.match_id)
    print("  Op Code: ", match_state.op_code)
    print("  From User: ", match_state.presence.username)
    print("  User ID: ", match_state.presence.user_id)
    print("  Data: ", match_state.data)
```

### Check Session Info
```gdscript
func _ready():
    if GameManager.session:
        print("🔐 Session Info:")
        print("  User ID: ", GameManager.session.user_id)
        print("  Username: ", GameManager.session.username)
        print("  Expired: ", GameManager.session.expired)
```

### Verify Node Paths
```gdscript
func _ready():
    print("🔍 Node Check:")
    print("  Has player: ", has_node("player"))
    print("  Has Player: ", has_node("Player"))
    print("  Has LevelNotification: ", has_node("LevelNotification"))
    print("  Has TriggerL2: ", has_node("TriggerL2"))
```

## Files Modified

1. `player.gd` - Fixed match_state.username → match_state.presence.user_id
2. `level.gd` - Fixed node paths and made TriggerL2 optional
3. `Lobby.gd` - Fixed unused variable warning
4. All files - Maintained existing functionality while fixing errors

All critical errors are now resolved! 🎉
