extends Node

var client: NakamaClient
var session: NakamaSession
var socket: NakamaSocket
var match_id: String = ""

func _ready():
	client = Nakama.create_client(
		"defaultkey",
		"127.0.0.1",
		7350,
		"http"
	)
	print("🎮 GameManager ready - Nakama client created")

func authenticate(email: String, password: String):
	session = await client.authenticate_email_async(email, password, null, true)
	if session.is_exception():
		print("Auth failed: ", session.get_exception())
		return
	print("Authenticated as: ", email)
	await connect_socket()

func connect_socket():
	if session == null:
		print("No session found!")
		return
	socket = Nakama.create_socket_from(client)
	await socket.connect_async(session)
	print("Socket connected!")

func create_match() -> String:
	if socket == null:
		print("Socket not connected!")
		return ""
	var match = await socket.create_match_async()
	if match.is_exception():
		print("Match creation failed: ", match.get_exception())
		return ""
	match_id = match.match_id
	print("Match created: ", match_id)
	return match_id

func join_match(id: String):
	if socket == null:
		print("Socket not connected!")
		return false
	var match = await socket.join_match_async(id)
	if match.is_exception():
		print("Join match failed: ", match.get_exception())
		return false
	match_id = id
	print("Joined match: ", match_id)
	return true

func leave_match():
	if socket != null and match_id != "":
		await socket.leave_match_async(match_id)
		match_id = ""
		print("Left match")
