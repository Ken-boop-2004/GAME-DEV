

<img width="1172" height="719" alt="Screenshot 2026-01-31 at 4 17 42 PM" src="https://github.com/user-attachments/assets/9e30881c-6fa2-4901-9df1-fd921c372258" />

<img width="1155" height="744" alt="{68B5CF33-9B9B-41E3-B58A-4E31896C682F}" src="https://github.com/user-attachments/assets/a45a6540-06a7-4fe5-8cba-86ab66c74b52" />


----MENU----

<img width="1920" height="1080" alt="{BD46780D-AE5C-4DCD-8345-11C2B58D5E2B}" src="https://github.com/user-attachments/assets/01b2a6d0-b862-4ad8-8bdb-08f4b4d7119e" />




----SETTINGS----

<img width="1920" height="1077" alt="{A53191C5-4FFD-4DDE-88F1-B628D074B86C}" src="https://github.com/user-attachments/assets/0140af34-a336-416b-944b-ceef4a5b29ba" />



----LEVEL 1 MAP----
<img width="1920" height="1080" alt="{356057F1-C601-4EFF-8E08-B445D1CCAC32}" src="https://github.com/user-attachments/assets/961da403-0035-45ec-b334-5d419d4968dd" />





----LEVEL 2 MAP----
<img width="1907" height="1080" alt="{3DBB79CA-22CE-47EA-A787-DB7516F01015}" src="https://github.com/user-attachments/assets/23574e91-6f49-4bfc-9e24-2106e33c7fe2" />

----ENEMY ENTITY IN LEVEL2 MAP----
<img width="1877" height="1080" alt="{1BE477BC-17C3-4B88-A929-A2653BBE85FA}" src="https://github.com/user-attachments/assets/80c9831b-517b-4c38-a485-df36e5958193" />

---Deployed 2D godot game using USB DEBUGGING for Mobile Phone---


![1000010385](https://github.com/user-attachments/assets/b1f86762-ab3c-4e69-b1c3-06ad8ed912ce)


![1000010386](https://github.com/user-attachments/assets/eec4b1e2-c943-477d-bc66-8c490b445be7)


---MULTIPLAYER MODE---
<img width="1920" height="1080" alt="{75FC84A0-5520-431D-8010-E3AF14515D1B}" src="https://github.com/user-attachments/assets/bc5345eb-4103-4a11-918a-327e5303532a" />


# Game Dev Subj

A 2D side-scrolling action platformer built with **Godot 4** and GDScript.

## About

Run through a looping castle environment, fight enemies, and survive as long as possible. Features a full main menu with video background, parallax scrolling, enemy AI, and an in-game settings screen.

## Features

- **Movement** — walk, sprint, variable jump with float cut
- **Dash / Double Jump** — one button does both: double jump when rising, dash when falling, dash on ground
- **Combat** — melee attack with proximity hit detection, invincibility frames on hit
- **Health Regen** — automatic regen after staying out of combat
- **Enemy AI** — patrol, chase, and attack states with distance-based detection and ledge raycasts
- **Parallax Background** — 4 auto-scrolling layers for depth
- **Level Progression** — speed increases after a distance threshold
- **Settings** — volume, brightness, fullscreen toggle, and keybind remapping

## Controls

| Action | Default Key |
|--------|-------------|
| Move | A / D |
| Jump | W |
| Sprint | Left Shift |
| Dash / Double Jump | Space |
| Attack | left-click mouse |

All keybinds are remappable in-game.

## Project Structure

```
player.gd          — Movement, combat, dash, double jump, regen, death
enemy.gd           — AI state machine (patrol → chase → attack), reset
global.gd          — Autoload: fullscreen, volume, scene switching
main_menu.gd       — Menu UI and video background
settings.gd        — Volume, brightness, fullscreen, keybind rebinding
level.gd           — Level loop, L2 transition, fall death
hazard.gd          — Instant-kill trigger areas
parallax_layer_*.gd — Auto-scrolling layers (speeds: 15, 30, 50, 75)
```

## Setup

1. Open the project in **Godot 4.x**
2. Set `res://main_menu.tscn` as the main scene in Project Settings
3. Make sure `Global.gd` is added as an Autoload named `Global`
4. Press **F5** to run

## Built With

- [Godot 4](https://godotengine.org/)
- GDScript

























Nakama Godot
===========

> Godot client for Nakama server written in GDScript.

[Nakama](https://github.com/heroiclabs/nakama) is an open-source server designed to power modern games and apps. Features include user accounts, chat, social, matchmaker, realtime multiplayer, and much [more](https://heroiclabs.com).

This client implements the full API and socket options with the server. It's written in GDScript to support Godot Engine `4.0+`.

Full documentation is online - https://heroiclabs.com/docs

## Godot 3 & 4

You're currently looking at the Godot 4 version of the Nakama client for Godot.

If you are using Godot 3, you need to use the ['master'
branch](https://github.com/heroiclabs/nakama-godot/tree/godot-4) on GitHub.

## Getting Started

You'll need to setup the server and database before you can connect with the client. The simplest way is to use Docker but have a look at the [server documentation](https://github.com/heroiclabs/nakama#getting-started) for other options.

1. Install and run the servers. Follow these [instructions](https://heroiclabs.com/docs/install-docker-quickstart).

2. Download the client from the [releases page](https://github.com/heroiclabs/nakama-godot/releases) and import it into your project. You can also [download it from the asset repository](#asset-repository).

3. Add the `Nakama.gd` singleton (in `addons/com.heroiclabs.nakama/`) as an [autoload in Godot](https://docs.godotengine.org/en/stable/getting_started/step_by_step/singletons_autoload.html).

4. Use the connection credentials to build a client object using the singleton.

    ```gdscript
    extends Node

    func _ready():
    	var scheme = "http"
    	var host = "127.0.0.1"
    	var port = 7350
    	var server_key = "defaultkey"
    	var client := Nakama.create_client(server_key, host, port, scheme)
    ```

## Usage

The client object has many methods to execute various features in the server or open realtime socket connections with the server.

### Authenticate

There's a variety of ways to [authenticate](https://heroiclabs.com/docs/authentication) with the server. Authentication can create a user if they don't already exist with those credentials. It's also easy to authenticate with a social profile from Google Play Games, Facebook, Game Center, etc.

```gdscript
	var email = "super@heroes.com"
	var password = "batsignal"
	# Use 'await' to wait for the request to complete.
	var session : NakamaSession = await client.authenticate_email_async(email, password)
	print(session)
```

### Sessions

When authenticated the server responds with an auth token (JWT) which contains useful properties and gets deserialized into a `NakamaSession` object.

```gdscript
	print(session.token) # raw JWT token
	print(session.user_id)
	print(session.username)
	print("Session has expired: %s" % session.expired)
	print("Session expires at: %s" % session.expire_time)
```

It is recommended to store the auth token from the session and check at startup if it has expired. If the token has expired you must reauthenticate. The expiry time of the token can be changed as a setting in the server.

```gdscript
	var authtoken = "restored from somewhere"
	var session2 = NakamaClient.restore_session(authtoken)
	if session2.expired:
		print("Session has expired. Must reauthenticate!")
```

NOTE: The length of the lifetime of a session can be changed on the server with the `--session.token_expiry_sec` command flag argument.

### Requests

The client includes lots of builtin APIs for various features of the game server. These can be accessed with the async methods. It can also call custom logic in RPC functions on the server. These can also be executed with a socket object.

All requests are sent with a session object which authorizes the client.

```gdscript
	var account = await client.get_account_async(session)
	print(account.user.id)
	print(account.user.username)
	print(account.wallet)
```

### Exceptions

Since Godot Engine does not support exceptions, whenever you make an async request via the client or socket, you can check if an error occurred via the `is_exception()` method.

```gdscript
	var an_invalid_session = NakamaSession.new() # An empty session, which will cause and error when we use it.
	var account2 = await client.get_account_async(an_invalid_session)
	print(account2) # This will print the exception
	if account2.is_exception():
		print("We got an exception")
```

### Socket

The client can create one or more sockets with the server. Each socket can have it's own event listeners registered for responses received from the server.

```gdscript
	var socket = Nakama.create_socket_from(client)
	socket.connected.connect(self._on_socket_connected)
	socket.closed.connect(self._on_socket_closed)
	socket.received_error.connect(self._on_socket_error)
	await socket.connect_async(session)
	print("Done")

func _on_socket_connected():
	print("Socket connected.")

func _on_socket_closed():
	print("Socket closed.")

func _on_socket_error(err):
	printerr("Socket error %s" % err)
```

## Integration with Godot's High-level Multiplayer API

Godot provides a [High-level Multiplayer
API](https://docs.godotengine.org/en/latest/tutorials/networking/high_level_multiplayer.html),
allowing developers to make RPCs, calling functions that run on other peers in
a multiplayer match.

For example:

```gdscript
func _process(delta):
	if not is_multiplayer_authority():
		return

	var input_vector = get_input_vector()

	# Move the player locally.
	velocity = input_vector * SPEED
	move_and_slide()

	# Then update the player's position on all other connected clients.
	update_remote_position.rpc(position)

@rpc(any_peer)
func update_remote_position(new_position):
	position = new_position
```

Godot provides a number of built-in backends for sending the RPCs, including:
ENet, WebSockets, and WebRTC.

However, you can also use the Nakama client as a backend! This can allow you to
continue using Godot's familiar High-level Multiplayer API, but with the RPCs
transparently sent over a realtime Nakama match.

To do that, you need to use the `NakamaMultiplayerBridge` class:

```gdscript
var multiplayer_bridge

func _ready():
	# [...]
	# You must have a working 'socket', created as described above.

	multiplayer_bridge = NakamaMultiplayerBridge.new(socket)
	multiplayer_bridge.match_join_error.connect(self._on_match_join_error)
	multiplayer_bridge.match_joined.connect(self._on_match_joined)
	get_tree().get_multiplayer().set_multiplayer_peer(multiplayer_bridge.multiplayer_peer)

func _on_match_join_error(error):
	print ("Unable to join match: ", error.message)

func _on_match_join() -> void:
	print ("Joined match with id: ", multiplayer_bridge.match_id)
```

You can also connect to any of the usual signals on `MultiplayerAPI`, for
example:

```gdscript
	get_tree().get_multiplayer().peer_connected.connect(self._on_peer_connected)
	get_tree().get_multiplayer().peer_disconnected.connect(self._on_peer_disconnected)

func _on_peer_connected(peer_id):
	print ("Peer joined match: ", peer_id)

func _on_peer_disconnected(peer_id):
	print ("Peer left match: ", peer_id)
```

Then you need to join a match, using one of the following methods:

- Create a new private match, with your client as the host.
  ```gdscript
  multiplayer_bridge.create_match()
  ```

- Join a private match.
  ```gdscript
  multiplayer_bridge.join_match(match_id)
  ```

- Create or join a private match with the given name.
  ```gdscript
  multiplayer_bridge.join_named_match(match_name)
  ```

- Use the matchmaker to find and join a public match.
  ```gdscript
  var ticket = await socket.add_matchmaker_async()
  if ticket.is_exception():
	print ("Error joining matchmaking pool: ", ticket.get_exception().message)
	return

  multiplayer_bridge.start_matchmaking(ticket)
  ```

After the the "match_joined" signal is emitted, you can start sending RPCs as
usual with the `rpc()` function, and calling any other functions associated with
the High-level Multiplayer API, such as `get_tree().get_multiplayer().get_unique_id()`
and `node.set_network_authority(peer_id)` and `node.is_network_authority()`.

## .NET / C#

If you're using the .NET version of Godot with C# support, you can use the
[Nakama .NET client](https://github.com/heroiclabs/nakama-dotnet/), which can be
installed via NuGet:

```
dotnet add package NakamaClient
```

This addon includes some C# classes for use with the .NET client, to provide deeper
integration with Godot:

- `GodotLogger`: A logger which prints to the Godot console.
- `GodotHttpAdapter`: An HTTP adapter which uses Godot's HTTPRequest node.
- `GodotWebSocketAdapter`: A socket adapter which uses Godot's WebSocketClient.

Here's an example of how to use them:

```csharp
	var http_adapter = new GodotHttpAdapter();
	// It's a Node, so it needs to be added to the scene tree.
	// Consider putting this in an autoload singleton so it won't go away unexpectedly.
	AddChild(http_adapter);

	const string scheme = "http";
	const string host = "127.0.0.1";
	const int port = 7350;
	const string serverKey = "defaultkey";

	// Pass in the 'http_adapter' as the last argument.
	var client = new Client(scheme, host, port, serverKey, http_adapter);

	// To log DEBUG messages to the Godot console.
	client.Logger = new GodotLogger("Nakama", GodotLogger.LogLevel.DEBUG);

	ISession session;
	try {
		session = await client.AuthenticateDeviceAsync(OS.GetUniqueId(), "TestUser", true);
	}
	catch (ApiResponseException e) {
		GD.PrintErr(e.ToString());
		return;
	}

	var websocket_adapter = new GodotWebSocketAdapter();
	// Like the HTTP adapter, it's a Node, so it needs to be added to the scene tree.
	// Consider putting this in an autoload singleton so it won't go away unexpectedly.
	AddChild(websocket_adapter);

	// Pass in the 'websocket_adapter' as the last argument.
	var socket = Socket.From(client, websocket_adapter);
```

**Note:** _The out-of-the-box Nakama .NET client will work fine with desktop builds of your game! However, it won't work with HTML5 builds, unless you use the `GodotHttpAdapter` and `GodotWebSocketAdapter` classes._

## Contribute

The development roadmap is managed as GitHub issues and pull requests are welcome. If you're interested to improve the code please open an issue to discuss the changes or drop in and discuss it in the [community forum](https://forum.heroiclabs.com).

### Run Tests

To run tests you will need to run the server and database. Most tests are written as integration tests which execute against the server. A quick approach we use with our test workflow is to use the Docker compose file described in the [documentation](https://heroiclabs.com/docs/install-docker-quickstart).

Additionally, you will need to copy (or symlink) the `addons` folder inside the `test_suite` folder. You can now run the `test_suite` project from the Godot Editor.

To run the tests on a headless machine (without a GPU) you can download a copy of [Godot Headless](https://godotengine.org/download/server) and run it from the command line.

To automate this procedure, move the headless binary to `test_suite/bin/godot.elf`, and run the tests via the `test_suite/run_tests.sh` shell script (exit code will report test failure/success).

```shell
cd nakama
docker-compose -f ./docker-compose-postgres.yml up
cd ..
cd nakama-godot
sh test_suite/run_tests.sh
```

### Make a new release

To make a new release ready for distribution, simply zip the addons folder recursively (possibly adding `CHANGELOG`, `LICENSE`, and `README.md` too).

On unix systems, you can run the following command (replacing `$VERSION` with the desired version number). Remember to update the `CHANGELOG` file first.

```shell
zip -r nakama-$VERSION.zip addons/ LICENSE CHANGELOG.md README.md
```

### License

This project is licensed under the [Apache-2 License](https://github.com/heroiclabs/nakama-godot/blob/master/LICENSE).
