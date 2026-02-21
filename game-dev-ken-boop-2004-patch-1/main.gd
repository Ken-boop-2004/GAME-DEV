extends Node2D
## Main game manager - handles level transitions

var current_level = 1
var level_scenes = {
	1: preload("res://level_1.tscn"),
	2: preload("res://level_2.tscn")
}
var current_level_instance = null
var player = null

@onready var level_container = $LevelContainer
@onready var level_label = $UI/LevelLabel


func _ready():
	load_level(1)


func load_level(level_number: int):
	"""Load a level and spawn player"""
	# Clear old level
	if current_level_instance:
		current_level_instance.queue_free()
	
	# Load new level
	current_level = level_number
	current_level_instance = level_scenes[level_number].instantiate()
	level_container.add_child(current_level_instance)
	
	# Get player spawn point
	var spawn_point = current_level_instance.get_node("PlayerSpawn")
	
	# Spawn or move player
	if player == null:
		# First time - create player
		player = preload("res://player.tscn").instantiate()
		current_level_instance.add_child(player)
	
	player.global_position = spawn_point.global_position
	player.velocity = Vector2.ZERO
	
	# Connect player signals
	if not player.is_connected("died", restart_level):
		player.died.connect(restart_level)
	if not player.is_connected("reached_goal", next_level):
		player.reached_goal.connect(reached_goal)
	
	# Update UI
	show_level_notification(level_number)


func restart_level():
	"""Restart current level after death"""
	print("Restarting level ", current_level)
	load_level(current_level)


func reached_goal():
	"""Player reached end of level"""
	if current_level == 1:
		# Go to level 2
		load_level(2)
	else:
		# Beat the game!
		print("YOU WIN! Game complete!")
		show_win_message()


func show_level_notification(level_num: int):
	"""Show level number on screen"""
	level_label.text = "LEVEL " + str(level_num)
	level_label.modulate.a = 1.0  # Fully visible
	
	# Fade out after 2 seconds
	var tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(level_label, "modulate:a", 0.0, 1.0)


func show_win_message():
	"""Show win message"""
	level_label.text = "YOU WIN!"
	level_label.modulate.a = 1.0
	
	# Optional: reload game after 3 seconds
	await get_tree().create_timer(3.0).timeout
	get_tree().reload_current_scene()
