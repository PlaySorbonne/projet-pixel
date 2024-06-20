extends Node2D

signal StartGame

@export var default_player: PackedScene

var keyboards = []
var controllers = []
var players = []
		
func _input(event):
	if event is InputEventKey:
		if event.device not in keyboards:
			add_player(event.device, 0)
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if event.device not in controllers:
			add_player(event.device, 1)

func add_player(device, device_type):
	if device_type == 0:
		keyboards.append(device)
	else:
		controllers.append(device)
	var player = default_player.instantiate()
	player.control_device = device
	player.control_type = device_type
	players.append(player)
	add_child(player)
	connect_fighter_to_world(player)
	player.spawn($SpawnPoint.position)

func connect_fighter_to_world(body : PlayerCharacter):
	body.fighter_died.connect(on_player_death)
	body.player_evolved.connect(connect_fighter_to_world)

func on_player_death(player : FighterCharacter):
	print("player " + str(player.character_id) + " died !!!")
	await get_tree().create_timer(3.0).timeout
	player.spawn($SpawnPoint.position)

func start_game():
	emit_signal("StartGame", players)
