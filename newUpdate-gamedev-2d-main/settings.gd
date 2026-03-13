extends Control

@onready var volume_slider: HSlider = $VBoxContainer/VolumeSlider
@onready var brightness_slider: HSlider = $VBoxContainer/BrightnessSlider
@onready var fullscreen_check: CheckButton = $VBoxContainer/FullscreenToggle
@onready var brightness_overlay: ColorRect = $BrightnessOverlay
@onready var keybind_jump: Button = $VBoxContainer/KeybindJump
@onready var keybind_attack: Button = $VBoxContainer/KeybindAttack
@onready var keybind_dash: Button = $VBoxContainer/KeybindDash
@onready var video: VideoStreamPlayer = $VideoStreamPlayer
var listening_for_key: String = ""

func _ready() -> void:
	# Set fullscreen at start (Godot 4 syntax)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	Global.is_fullscreen = true

	# Sync UI to current global state
	fullscreen_check.button_pressed = Global.is_fullscreen
	volume_slider.value = Global.master_volume
	brightness_slider.value = 0.0

	var vsp = $VideoStreamPlayer
	vsp.anchor_left = 0
	vsp.anchor_top = 0
	vsp.anchor_right = 1
	vsp.anchor_bottom = 1
	vsp.offset_left = 0
	vsp.offset_top = 0
	vsp.offset_right = 0
	vsp.offset_bottom = 0
	vsp.expand = true
	if not vsp.is_playing():
		vsp.play()

	volume_slider.value_changed.connect(_on_volume_changed)
	brightness_slider.value_changed.connect(_on_brightness_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	keybind_jump.pressed.connect(func(): _start_rebind("jump", keybind_jump))
	keybind_attack.pressed.connect(func(): _start_rebind("attack", keybind_attack))
	keybind_dash.pressed.connect(func(): _start_rebind("dash", keybind_dash))
	$VBoxContainer/BtnBack.pressed.connect(_on_back)
	_update_keybind_labels()
func _on_volume_changed(value: float) -> void:
	Global.set_master_volume(value)


func _on_brightness_changed(value: float) -> void:
	brightness_overlay.color = Color(0, 0, 0, value)

func _on_fullscreen_toggled(on: bool) -> void:
	Global.set_fullscreen(on)
func _start_rebind(action: String, btn: Button) -> void:
	listening_for_key = action
	btn.text = "PRESS ANY KEY..."

func _input(event: InputEvent) -> void:
	if listening_for_key == "":
		return
	if event is InputEventKey and event.pressed:
		InputMap.action_erase_events(listening_for_key)
		InputMap.action_add_event(listening_for_key, event)
		listening_for_key = ""
		_update_keybind_labels()
		get_viewport().set_input_as_handled()

func _update_keybind_labels() -> void:
	keybind_jump.text = "JUMP: " + _get_key_label("jump")
	keybind_attack.text = "ATTACK: " + _get_key_label("attack")
	keybind_dash.text = "DASH: " + _get_key_label("dash")

func _get_key_label(action: String) -> String:
	var events = InputMap.action_get_events(action)
	if events.size() > 0 and events[0] is InputEventKey:
		return events[0].as_text()
	return "UNSET"

func _on_back() -> void:
	video.stop()
	get_tree().change_scene_to_file("res://main_menu.tscn")
	
