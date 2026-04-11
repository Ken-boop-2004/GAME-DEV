extends Control

var match_created: bool = false
var already_switching: bool = false

func _ready() -> void:
	$VBoxContainer/BtnCreate.pressed.connect(_on_create_pressed)
	$VBoxContainer/HBoxContainer/BtnJoin.pressed.connect(_on_join_pressed)
	$VBoxContainer/BtnBack.pressed.connect(_on_back_pressed)

func _on_create_pressed():
	if match_created:
		return
	match_created = true
	var match_id = await GameManager.create_match()
	if match_id == null or match_id == "":
		print("Failed to create match!")
		match_created = false
		return
	$VBoxContainer/HBoxContainer/MatchIdInput.text = match_id
	$VBoxContainer/MatchIdLabel.text = "Match ID: " + match_id
	print("Share this ID with Player 2: ", match_id)

func _on_join_pressed():
	if already_switching:
		return
	var match_id = $VBoxContainer/HBoxContainer/MatchIdInput.text.strip_edges()
	if match_id == "" or match_id == "Enter Match ID":
		print("Please enter a Match ID!")
		return
	print("Joining match: ", match_id)
	var _result = await GameManager.join_match(match_id)
	print("Join result, switching scene now")
	already_switching = true
	get_tree().change_scene_to_file("res://level.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
