extends CharacterBody2D

enum State { PATROL, CHASE, ATTACK }

@export var speed: float = 120.0
@export var gravity: float = 1800.0
@export var patrol_direction: float = 1.0  # 1 = right, -1 = left

var current_state: State = State.PATROL
var player_ref: Node2D = null

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_left: RayCast2D = $RayLeft
@onready var ray_right: RayCast2D = $RayRight
@onready var detection: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea

func _ready() -> void:
	detection.body_entered.connect(_on_detect_enter)
	detection.body_exited.connect(_on_detect_exit)
	attack_area.body_entered.connect(_on_attack_hit)
	print("🦹 ENEMY READY! Position: ", global_position)
	sprite.play("idle")  # Force it
	sprite.visible = true  # Double force
	print("Enemy sprite forced visible & playing idle")  # Force start idle animation

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	match current_state:
		State.PATROL:
			patrol_behavior()
		State.CHASE:
			chase_behavior()
		State.ATTACK:
			attack_behavior()

	move_and_slide()
	update_sprite()

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

func attack_behavior() -> void:
	velocity.x = move_toward(velocity.x, 0, speed)

func _on_detect_enter(body: Node2D) -> void:
	print("🔍 Detected: ", body.name)
	if body.name == "Player" or body.is_in_group("player"):
		player_ref = body
		current_state = State.CHASE
		sprite.play("walk")

func _on_detect_exit(body: Node2D) -> void:
	if body == player_ref:
		player_ref = null
		current_state = State.PATROL
		sprite.play("idle")

func _on_attack_hit(body: Node2D) -> void:
	print("💥 Attacked: ", body.name)
	if body.name == "Player":
		body.die()
		current_state = State.PATROL
		sprite.play("idle")

func update_sprite() -> void:
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
