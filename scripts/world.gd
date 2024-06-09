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
		player.fighter_died.connect(on_player_death)
		player_spawns[player] = spawn_locations[player_number].position
		player.spawn(player_spawns[player])
		player_number += 1

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func on_player_death(player : FighterCharacter):
	print("player " + str(player.character_id) + " died !!!")
	await get_tree().create_timer(3.0).timeout
	player.spawn(player_spawns[player])

