extends Node

# ── Window / Display ────────────────────────────────────────
var is_fullscreen: bool = true

# ── Audio ────────────────────────────────────────────────────
var master_volume: float = 1.0
var music_volume: float = 1.0

# ── Game State ───────────────────────────────────────────────
var current_level: String = "res://level.tscn"

func _ready() -> void:
	# Set window size on startup then go fullscreen
	get_window().size = Vector2i(1280, 720)
	get_window().min_size = Vector2i(1280, 720)
	get_window().move_to_center()
	set_fullscreen(true)

# ── Fullscreen ───────────────────────────────────────────────
func set_fullscreen(on: bool) -> void:
	is_fullscreen = on
	if on:
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED
		get_window().size = Vector2i(1280, 720)
		get_window().move_to_center()

# ── Volume ───────────────────────────────────────────────────
func set_master_volume(value: float) -> void:
	master_volume = value
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func set_music_volume(value: float) -> void:
	music_volume = value
	# Bus 1 = Music bus (set this up in Audio panel if needed)
	if AudioServer.get_bus_count() > 1:
		AudioServer.set_bus_volume_db(1, linear_to_db(value))

# ── Scene Switching ──────────────────────────────────────────
func go_to_scene(path: String) -> void:
	if ResourceLoader.exists(path):
		get_tree().change_scene_to_file(path)
	else:
		printerr("❌ Scene not found: ", path)

func go_to_main_menu() -> void:
	get_tree().paused = false
	go_to_scene("res://main_menu.tscn")

func go_to_level() -> void:
	get_tree().paused = false
	go_to_scene(current_level)
