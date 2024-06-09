extends Node2D

@onready var spawn_locations : Array = [
	$SpawnLocation1,
	$SpawnLocation2,
	$SpawnLocation3,
	$SpawnLocation4
]

func _ready():
	var player_number = 0
	for player : CharacterBody2D in GameInfos.players:
		add_child(player)
		player.position = spawn_locations[player_number].position
		player_number += 1

