extends CharacterBody2D

# ── Multiplayer ─────────────────────────────────────────────
@export var is_local_player: bool = true
var player_id: String = ""

# ── Movement ────────────────────────────────────────────────
@export var auto_run_speed : float = 250.0
@export var max_run_speed : float = 450.0
@export var sprint_speed : float = 400.0
@export var acceleration : float = 1800.0
@export var friction : float = 1400.0
@export var jump_velocity : float = -920.0
@export var gravity : float = 1800.0

# ── Dash ────────────────────────────────────────────────────
@export var dash_speed : float = 600.0
@export var dash_duration : float = 0.15
@export var dash_cooldown : float = 0.9
var is_dashing : bool = false
var has_double_jumped : bool = false
var dash_timer : float = 0.0
var dash_cooldown_timer : float = 0.0
var dash_direction : Vector2 = Vector2.RIGHT

# ── Sprint ───────────────────────────────────────────────────
var is_sprinting : bool = false

# ── Fall Death & Respawn ────────────────────────────────────
@export var death_y : float = 600.0
@export var spawn_position : Vector2 = Vector2(0, 0)

# ── Combat ──────────────────────────────────────────────────
@export var max_hp : int = 100
var current_hp : int = 100
@export var attack_damage : int = 10
@export var attack_cooldown : float = 0.5
var attack_timer : float = 0.0
var attack_queued : bool = false
var is_attacking : bool = false
var attack_anim_timer : float = 0.0
@export var attack_anim_duration : float = 0.4
var is_invincible : bool = false

# ── Regen ────────────────────────────────────────────────────
@export var regen_amount : int = 5
@export var regen_interval : float = 3.0
@export var regen_delay : float = 5.0
var regen_timer : float = 0.0
var regen_delay_timer : float = 0.0
var can_regen : bool = true

# ── Trackers ────────────────────────────────────────────────
var total_distance : float = 0.0

# ── Sync timer ──────────────────────────────────────────────
var sync_timer: float = 0.0
var sync_interval: float = 0.05 # Send position 20 times per second

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area : Area2D = $AttackArea
var health_bar : ProgressBar = null

func _ready() -> void:
	global_position = spawn_position
	current_hp = max_hp
	if has_node("HealthBar"):
		health_bar = $HealthBar
		health_bar.max_value = max_hp
		health_bar.value = current_hp
		print("✅ HealthBar connected!")
	else:
		printerr("❌ HealthBar not found!")
	if not attack_area:
		printerr("AttackArea node missing!")
	attack_anim_timer = 0.0
	
	# Connect Nakama match state receiver (only for local player in multiplayer)
	if is_local_player and GameManager.socket and GameManager.match_id != "":
		GameManager.socket.received_match_state.connect(_on_match_state)
		print("🌐 Multiplayer sync enabled for local player")

func _physics_process(delta: float) -> void:
	# If this is the remote player, skip local input
	if not is_local_player:
		move_and_slide()
		_update_animation()
		return
	
	total_distance += velocity.x * delta

	# Gravity
	if not is_on_floor() and not is_dashing:
		velocity.y += gravity * delta

	# Reset double jump when landing
	if is_on_floor():
		has_double_jumped = false

	# Sprint check
	is_sprinting = Input.is_action_pressed("sprint") and not is_dashing

	# Movement
	if not is_dashing:
		var direction = Input.get_axis("move_left", "move_right")
		var target_speed = sprint_speed if is_sprinting else auto_run_speed
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * target_speed, acceleration * delta)
			sprite.flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Dash / Double Jump
	if Input.is_action_just_pressed("dash") and not is_dashing and dash_cooldown_timer <= 0:
		if not is_on_floor():
			if velocity.y <= 0 and not has_double_jumped:
				velocity.y = jump_velocity
				has_double_jumped = true
			else:
				start_dash()
		else:
			start_dash()

	if is_dashing:
		velocity = dash_direction * dash_speed
		dash_timer -= delta
		if dash_timer <= 0:
			end_dash()
	dash_cooldown_timer = maxf(dash_cooldown_timer - delta, 0)

	# Attack
	attack_timer = maxf(attack_timer - delta, 0)
	if Input.is_action_just_pressed("attack"):
		attack_queued = true
	if attack_queued and attack_timer <= 0 and not is_attacking:
		attack()
		attack_timer = attack_cooldown
		attack_queued = false

	# Force-clear attack animation after duration
	if is_attacking:
		attack_anim_timer -= delta
		if attack_anim_timer <= 0:
			is_attacking = false

	# Regen
	if not can_regen:
		regen_delay_timer -= delta
		if regen_delay_timer <= 0:
			can_regen = true
			regen_timer = 0.0
	if can_regen and current_hp < max_hp:
		regen_timer -= delta
		if regen_timer <= 0:
			heal(regen_amount)
			regen_timer = regen_interval

	# Apply movement
	move_and_slide()

	# Fall death
	if global_position.y > death_y:
		die()

	# Animations
	_update_animation()
	
	# Send position to other player (only in multiplayer)
	if is_local_player and GameManager.match_id != "":
		sync_timer -= delta
		if sync_timer <= 0:
			sync_timer = sync_interval
			_send_state()

# ── Nakama Sync ─────────────────────────────────────────────
func _send_state() -> void:
	if not GameManager.socket or GameManager.match_id == "":
		return
	var state = {
		"x": global_position.x,
		"y": global_position.y,
		"vx": velocity.x,
		"vy": velocity.y,
		"flip": sprite.flip_h,
		"anim": sprite.animation
	}
	GameManager.socket.send_match_state_async(
		GameManager.match_id, 1, JSON.stringify(state)
	)

func _on_match_state(match_state) -> void:
	# Ignore our own messages - only process state from other players
	if match_state.op_code == 1:
		# Check if this is from another player (not us)
		# match_state.presence contains the sender's info
		if GameManager.session and match_state.presence and match_state.presence.user_id == GameManager.session.user_id:
			return  # Skip our own state updates
		
		var data = JSON.parse_string(match_state.data)
		if data == null:
			return
		
		# Find the remote player node and update it
		var remote = get_tree().get_first_node_in_group("remote_player")
		if remote:
			remote.global_position = Vector2(data["x"], data["y"])
			remote.velocity = Vector2(data["vx"], data["vy"])
			remote.sprite.flip_h = data["flip"]
			if remote.sprite.animation != data["anim"]:
				remote.sprite.play(data["anim"])

# ── Everything below is unchanged ───────────────────────────

func heal(amount: int) -> void:
	current_hp = mini(current_hp + amount, max_hp)
	if health_bar:
		health_bar.value = current_hp
	print("💚 Regen: ", current_hp, " / ", max_hp)

func _update_animation() -> void:
	if is_attacking:
		_play_anim("attack")
	elif is_dashing:
		_play_anim("dash", "run")
	elif not is_on_floor():
		if velocity.y > 0:
			_play_anim("fall", "jump")
		else:
			_play_anim("jump")
	elif is_sprinting and abs(velocity.x) > 20:
		_play_anim("run")
	elif abs(velocity.x) > 20:
		_play_anim("run")
	else:
		_play_anim("idle")

func _play_anim(anim: String, fallback: String = "") -> void:
	var target : String = ""
	if sprite.sprite_frames.has_animation(anim):
		target = anim
	elif fallback != "" and sprite.sprite_frames.has_animation(fallback):
		target = fallback
	else:
		return
	if sprite.animation != target or not sprite.is_playing():
		sprite.play(target)

func start_dash() -> void:
	is_dashing = true
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	var h = Input.get_axis("move_left", "move_right")
	var dir = Vector2(h, 0)
	if dir == Vector2.ZERO:
		dir.x = -1.0 if sprite.flip_h else 1.0
	dash_direction = dir.normalized()

func end_dash() -> void:
	is_dashing = false

func attack() -> void:
	is_attacking = true
	attack_anim_timer = attack_anim_duration
	_play_anim("attack")
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == self:
			continue
		if not enemy.has_method("take_damage"):
			continue
		if global_position.distance_to(enemy.global_position) <= 150.0:
			enemy.take_damage(attack_damage)

func take_damage(amount: int) -> void:
	if is_invincible:
		return
	if current_hp <= 0:
		return
	current_hp -= amount
	if health_bar:
		health_bar.value = current_hp
	print("Player HP: ", current_hp)
	can_regen = false
	regen_delay_timer = regen_delay
	is_invincible = true
	sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.4).timeout
	if is_instance_valid(self):
		sprite.modulate = Color(1, 1, 1)
		is_invincible = false
	if current_hp <= 0:
		die()

func die() -> void:
	is_invincible = false
	is_attacking = false
	is_dashing = false
	is_sprinting = false
	has_double_jumped = false
	attack_anim_timer = 0.0
	can_regen = true
	regen_timer = 0.0
	regen_delay_timer = 0.0
	velocity = Vector2.ZERO
	total_distance = 0.0
	dash_cooldown_timer = 0.0
	current_hp = max_hp
	if health_bar:
		health_bar.value = max_hp
	sprite.modulate = Color(1, 1, 1)
	global_position = spawn_position
	print("Player died → respawned at ", spawn_position)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("reset"):
			enemy.reset()

func _input(event: InputEvent) -> void:
	if event.is_action_released("jump") and velocity.y < 0:
		velocity.y *= 0.45
