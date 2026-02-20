extends CharacterBody2D

var speed = 200.0
var jump_power = -400.0
var gravity = 980.0

var spawn_position = Vector2.ZERO
var death_y_limit = 1000

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	spawn_position = global_position


func _physics_process(delta):

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_power

	# Movement input
	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed

	# Flip sprite
	if direction != 0:
		anim.flip_h = direction < 0

	move_and_slide()

	# -------- FIXED ANIMATION LOGIC --------
	if not is_on_floor():
		if anim.animation != "jump":
			anim.play("jump")

	elif abs(velocity.x) > 1:   # 👈 check real movement
		if anim.animation != "run":
			anim.play("run")

	else:
		if anim.animation != "idle":
			anim.play("idle")

	# Death check
	if global_position.y > death_y_limit:
		die_and_respawn()


func die_and_respawn():
	global_position = spawn_position
	velocity = Vector2.ZERO
