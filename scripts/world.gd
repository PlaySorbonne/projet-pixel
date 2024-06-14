extends Node2D

@onready var spawn_locations : Array = [
	$SpawnLocation1,
	$SpawnLocation2,
	$SpawnLocation3,
	$SpawnLocation4
]

var player_spawns = {}



func _testing_function():
	var freezeframe : FreezeFrame = $Camera/FreezeFrame
	var screenshake : CameraUtils = $Camera/CameraUtils
	while true:
		await get_tree().create_timer(2.0).timeout
		#freezeframe.freeze()
		screenshake.shake()


func _ready():
	#_testing_function()
	var player_number = 0
	"""if len(GameInfos.players) == 1:
		GameInfos.players.append(PlayerCharacter.EvolutionCharacters[0].instantiate())
		GameInfos.players[1].control_device = -1"""
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

