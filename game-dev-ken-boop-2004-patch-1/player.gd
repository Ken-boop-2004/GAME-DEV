extends Node2D

# ================= LEVEL SYSTEM =================
var current_level = 1
var level_scenes = {
	1: preload("res://level_1.tscn"),
	2: preload("res://level_2.tscn")
}

var current_level_instance = null
var player = null
var current_checkpoint = null
var is_transitioning = false

# ================= REFERENCES =================
@onready var level_container = $LevelContainer
@onready var level_label = $UI/LevelLabel
@onready var fade_rect = $Fade
@onready var camera = $Camera2D


func _ready():
	load_level(1)


# ==================================================
# LOAD LEVEL
# ==================================================
func load_level(level_number: int):

	if current_level_instance:
		current_level_instance.queue_free()

	current_level = level_number
	current_level_instance = level_scenes[level_number].instantiate()
	level_container.add_child(current_level_instance)

	var spawn_point = current_level_instance.get_node("PlayerSpawn")

	if player == null:
		player = preload("res://player.tscn").instantiate()
		current_level_instance.add_child(player)

	player.global_position = spawn_point.global_position
	player.velocity = Vector2.ZERO

	current_checkpoint = spawn_point

	connect_player_signals()

	show_level_notification(level_number)


func connect_player_signals():
	if not player.is_connected("died", restart_from_checkpoint):
		player.died.connect(restart_from_checkpoint)

	if not player.is_connected("reached_goal", reached_goal):
		player.reached_goal.connect(reached_goal)


# ==================================================
# CHECKPOINT SYSTEM
# ==================================================
func set_checkpoint(checkpoint_node):
	current_checkpoint = checkpoint_node
	print("Checkpoint updated!")


func restart_from_checkpoint():
	await play_death_sequence()

	player.global_position = current_checkpoint.global_position
	player.velocity = Vector2.ZERO


# ==================================================
# LEVEL COMPLETE
# ==================================================
func reached_goal():
	await fade_transition()

	if current_level < level_scenes.size():
		load_level(current_level + 1)
	else:
		show_win_message()


# ==================================================
# DEATH SEQUENCE (ANIMATION + SHAKE)
# ==================================================
func play_death_sequence():

	player.anim.play("idle")  # or play custom death anim if you add one
	camera_shake(0.4, 8)

	await get_tree().create_timer(0.6).timeout


# ==================================================
# CAMERA SHAKE
# ==================================================
func camera_shake(duration: float, strength: float):

	var original_position = camera.position
	var shake_time = 0.0

	while shake_time < duration:
		shake_time += get_process_delta_time()

		var offset = Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)

		camera.position = original_position + offset
		await get_tree().process_frame

	camera.position = original_position


# ==================================================
# FADE TRANSITION
# ==================================================
func fade_transition():

	if is_transitioning:
		return

	is_transitioning = true

	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.4)
	await tween.finished

	tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.4)
	await tween.finished

	is_transitioning = false


# ==================================================
# UI
# ==================================================
func show_level_notification(level_num: int):

	level_label.text = "LEVEL " + str(level_num)
	level_label.modulate.a = 1.0

	var tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(level_label, "modulate:a", 0.0, 1.0)


func show_win_message():

	level_label.text = "YOU WIN!"
	level_label.modulate.a = 1.0

	await get_tree().create_timer(3.0).timeout
	get_tree().reload_current_scene()
