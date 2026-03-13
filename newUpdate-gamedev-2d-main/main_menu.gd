extends Control

@onready var video: VideoStreamPlayer = $VideoStreamPlayer


func _ready() -> void:
	# Force root control to fill window
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0

	# Force video to fill entire screen
	var vsp = $VideoStreamPlayer
	vsp.anchor_left = 0
	vsp.anchor_top = 0
	vsp.anchor_right = 1
	vsp.anchor_bottom = 1
	vsp.offset_left = -50
	vsp.offset_top = -50
	vsp.offset_right = 50
	vsp.offset_bottom = 50
	vsp.expand = true

	if not vsp.is_playing():
		vsp.play()

	# Connect buttons
	$VBoxContainer/BtnPlay.pressed.connect(_on_play)
	$VBoxContainer/BtnSettings.pressed.connect(_on_settings)
	$VBoxContainer/BtnQuit.pressed.connect(_on_quit)

func _on_play() -> void:
	video.stop()
	Global.go_to_level()

func _on_settings() -> void:
	video.stop()
	Global.go_to_scene("res://settings.tscn")

func _on_quit() -> void:
	get_tree().quit()
