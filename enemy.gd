extends CharacterBody2D

enum State { PATROL, CHASE, ATTACK }

@export var speed: float = 120.0
@export var gravity: float = 1800.0
@export var patrol_direction: float = 1.0

# ── HP System ───────────────────────────────────────────────
@export var max_hp: int = 100
var current_hp: int = 100
var is_dead: bool = false

# ── Attack ──────────────────────────────────────────────────
@export var attack_range: float = 200.0
@export var detection_range: float = 500.0  # how far enemy can see player
@export var attack_cooldown: float = 0.8
var attack_timer: float = 0.0

var current_state: State = State.PATROL
var player_ref: Node2D = null
var spawn_pos: Vector2 = Vector2.ZERO
var spawn_patrol_direction: float = 1.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_left: RayCast2D = $RayLeft
@onready var ray_right: RayCast2D = $RayRight
@onready var detection: Area2D = $DetectionArea
@onready var health_bar: ProgressBar = $HealthBar

func _ready() -> void:
	add_to_group("enemies")
	spawn_pos = global_position
	spawn_patrol_direction = patrol_direction
	current_hp = max_hp
	is_dead = false
	detection.body_entered.connect(_on_detect_enter)
	detection.body_exited.connect(_on_detect_exit)
	sprite.visible = true
	sprite.modulate = Color(1, 1, 1)
	sprite.play("static")
	health_bar.max_value = max_hp
	health_bar.value = current_hp
	print("🦹 ENEMY READY! Position: ", global_position)

func reset() -> void:
	print("🔄 Enemy reset to: ", spawn_pos)
	is_dead = false
	global_position = spawn_pos
	current_hp = max_hp
	velocity = Vector2.ZERO
	player_ref = null
	current_state = State.PATROL
	patrol_direction = spawn_patrol_direction
	attack_timer = 0.0
	sprite.modulate = Color(1, 1, 1)
	sprite.visible = true
	sprite.play("static")
	health_bar.value = max_hp
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	attack_timer = maxf(attack_timer - delta, 0)

	if not is_on_floor():
		velocity.y += gravity * delta

	# ── Always scan for player in range regardless of direction ──
	_scan_for_player()

	if player_ref:
		var dist = global_position.distance_to(player_ref.global_position)
		if dist <= attack_range:
			current_state = State.ATTACK
		elif dist <= detection_range:
			current_state = State.CHASE
		else:
			# Player walked too far away
			player_ref = null
			current_state = State.PATROL

		if current_state == State.ATTACK and attack_timer <= 0:
			player_ref.take_damage(10)
			attack_timer = attack_cooldown
			print("👊 Enemy attacked player!")

	match current_state:
		State.PATROL:
			patrol_behavior()
		State.CHASE:
			chase_behavior()
		State.ATTACK:
			attack_behavior(delta)

	move_and_slide()
	update_animation()

func _scan_for_player() -> void:
	# Scan all players in the scene directly by distance — no direction bias
	if player_ref and is_instance_valid(player_ref):
		return  # already tracking player
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		var dist = global_position.distance_to(p.global_position)
		if dist <= detection_range:
			player_ref = p
			current_state = State.CHASE
			return
	# Also try finding by name if not in group
	var player_node = get_tree().get_root().find_child("Player", true, false)
	if player_node and is_instance_valid(player_node):
		var dist = global_position.distance_to(player_node.global_position)
		if dist <= detection_range:
			player_ref = player_node
			current_state = State.CHASE

func patrol_behavior() -> void:
	velocity.x = patrol_direction * speed
	if ray_left.is_colliding() and patrol_direction < 0:
		patrol_direction = 1.0
	if ray_right.is_colliding() and patrol_direction > 0:
		patrol_direction = -1.0

func chase_behavior() -> void:
	if player_ref:
		var direction = sign(player_ref.global_position.x - global_position.x)
		velocity.x = direction * speed
		if ray_left.is_colliding() and direction < 0:
			velocity.x = 0
		if ray_right.is_colliding() and direction > 0:
			velocity.x = 0

func attack_behavior(_delta: float) -> void:
	if player_ref:
		var dist = global_position.distance_to(player_ref.global_position)
		# Slowly walk toward player if they drift out of melee range
		if dist > attack_range * 0.8:
			var direction = sign(player_ref.global_position.x - global_position.x)
			velocity.x = direction * (speed * 0.5)
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
		sprite.flip_h = player_ref.global_position.x < global_position.x

func _on_detect_enter(body: Node2D) -> void:
	if body == self or body.is_in_group("platforms"):
		return
	if body.name == "Player" or body.is_in_group("player"):
		player_ref = body
		current_state = State.CHASE

func _on_detect_exit(body: Node2D) -> void:
	if body == player_ref:
		# Don't immediately lose player — let distance check handle it
		pass

func take_damage(amount: int) -> void:
	if is_dead:
		return
	current_hp -= amount
	health_bar.value = current_hp
	print("💥 Enemy hit! HP: ", current_hp, " / ", max_hp)

	# Always chase whoever hit us
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0]
		current_state = State.CHASE

	sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.15).timeout
	if not is_dead:
		sprite.modulate = Color(1, 1, 1)
	if current_hp <= 0:
		die()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	print("💀 Enemy killed!")
	velocity = Vector2.ZERO
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	if sprite.sprite_frames.has_animation("death"):
		sprite.play("death")
		await sprite.animation_finished
	else:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 0.4)
		await tween.finished
	queue_free()

func update_animation() -> void:
	match current_state:
		State.PATROL, State.CHASE:
			if velocity.x > 0:
				sprite.flip_h = false
			elif velocity.x < 0:
				sprite.flip_h = true
			if abs(velocity.x) > 0:
				sprite.play("walk")
			else:
				sprite.play("static")
		State.ATTACK:
			if player_ref:
				sprite.flip_h = player_ref.global_position.x < global_position.x
			if sprite.sprite_frames.has_animation("attack"):
				if sprite.animation != "attack":
					sprite.play("attack")
			else:
				sprite.play("static")
