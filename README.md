

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
