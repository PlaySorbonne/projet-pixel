extends Node2D
class_name Level

@onready var SpawnPoints : Array[Node2D] = [
	$SpawnLocation1,
	$SpawnLocation2,
	$SpawnLocation3,
	$SpawnLocation4
]
@onready var PlayerCamera : Camera2D = $Camera
