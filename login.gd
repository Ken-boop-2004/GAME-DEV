extends Control

@onready var email_input = $VBoxContainer/EmailInput
@onready var password_input = $VBoxContainer/PasswordInput
@onready var login_button = $VBoxContainer/LoginButton

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
	
	login_button.connect("pressed", _on_login_pressed)

func _on_login_pressed():
	var email = email_input.text
	var password = password_input.text
	
	if email == "" or password == "":
		print("Please enter email and password!")
		return
	
	print("Logging in as: ", email)
	await GameManager.authenticate(email, password)
	
	if GameManager.session == null or GameManager.session.is_exception():
		print("Login failed!")
		return
	
	# Use call_deferred to safely change scene
	call_deferred("_go_to_main_menu")

func _go_to_main_menu():
	get_tree().change_scene_to_file("res://main_menu.tscn")
