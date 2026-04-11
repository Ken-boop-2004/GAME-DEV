extends Node2D

@export var level_length: float = 8000.0
@export var l2_start: float = 4000.0
@export var death_y: float = 600.0          # Adjust: die if player falls below this Y
@export var spawn_pos: Vector2 = Vector2(100, 300)

var in_l2: bool = false
var remote_player: CharacterBody2D = null
var is_multiplayer: bool = false

@onready var player = $player
@onready var level_notification: Label = $LevelNotification
@onready var trigger_l2: Area2D = null  # Will try to find it if it exists

func _ready():
	# Try to find TriggerL2 if it exists
	if has_node("TriggerL2"):
		trigger_l2 = $TriggerL2
		trigger_l2.body_entered.connect(_on_l2_trigger)
	
	if not player:
		print("ERROR: Player node not found!")
		return
	
	# Check if we're in multiplayer mode
	is_multiplayer = GameManager.match_id != null and GameManager.match_id != ""
	
	if is_multiplayer:
		print("🎮 Multiplayer mode detected!")
		_spawn_remote_player()
		# Listen for match presence events
		if GameManager.socket:
			GameManager.socket.received_match_presence.connect(_on_match_presence)
	else:
		print("🎮 Single-player mode")

func _process(_delta):
	if not player:
		return

	# Fall death
	if player.global_position.y > death_y:
		die()
		return

	# Endless loop reset
	if player.global_position.x > level_length:
		player.global_position.x -= level_length
		player.total_distance = 0

	# Level 2 transition
	if player.total_distance > l2_start and not in_l2:
		enter_l2()

func _on_l2_trigger(body):
	if body == player:
		enter_l2()

func die():
	player.global_position = spawn_pos
	player.velocity = Vector2.ZERO
	player.total_distance = 0
	player.auto_run_speed = 250.0   # Reset to easy speed
	in_l2 = false
	if level_notification:
		level_notification.visible = false
	print("Player fell → Died & revived at ", spawn_pos)

func enter_l2():
	in_l2 = true
	player.auto_run_speed = 350.0
	show_notification()

func show_notification():
	if level_notification:
		level_notification.visible = true
		var tween = create_tween()
		tween.tween_property(level_notification, "modulate:a", 0.0, 2.0).from(1.0)
		await tween.finished
		level_notification.visible = false

func _spawn_remote_player():
	var remote_scene = preload("res://RemotePlayer.tscn")
	remote_player = remote_scene.instantiate()
	remote_player.global_position = spawn_pos + Vector2(50, 0)  # Spawn slightly offset
	remote_player.add_to_group("remote_player")
	add_child(remote_player)
	print("✅ Remote player spawned!")

func _on_match_presence(presence_event):
	print("👥 Match presence event:")
	print("  Joins: ", presence_event.joins.size())
	print("  Leaves: ", presence_event.leaves.size())
	
	# When someone joins, spawn remote player if not already spawned
	if presence_event.joins.size() > 0 and remote_player == null:
		_spawn_remote_player()
	
	# When someone leaves, remove remote player
	if presence_event.leaves.size() > 0 and remote_player != null:
		remote_player.queue_free()
		remote_player = null
		print("❌ Remote player removed")
