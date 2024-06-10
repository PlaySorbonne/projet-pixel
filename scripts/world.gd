extends Node2D

@onready var spawn_locations : Array = [
	$SpawnLocation1,
	$SpawnLocation2,
	$SpawnLocation3,
	$SpawnLocation4
]

var player_spawns = {}

func _ready():
	var player_number = 0
	for player : PlayerCharacter in GameInfos.players:
		add_child(player)
		connect_fighter_to_world(player)
		player_spawns[player.character_id] = spawn_locations[player_number].position
		player.spawn(player_spawns[player.character_id])
		player_number += 1

func connect_fighter_to_world(body : PlayerCharacter):
	body.fighter_died.connect(on_player_death)
	body.player_evolved.connect(connect_fighter_to_world)

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func on_player_death(player : FighterCharacter):
	print("player " + str(player.character_id) + " died !!!")
	print("respawn points: " + str(player_spawns) + " char_id = " + str(player.character_id))
	await get_tree().create_timer(3.0).timeout
	player.spawn(player_spawns[player.character_id])

