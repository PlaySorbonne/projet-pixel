extends Node2D
class_name Level

@onready var spawn_points : Array[Node2D] = [
	$SpawnLocation1,
	$SpawnLocation2,
	$SpawnLocation3,
	$SpawnLocation4
]
@onready var player_camera : Camera2D = $Camera
