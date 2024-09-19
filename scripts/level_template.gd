extends Node2D
class_name Level


const ANIME_BOX = preload("res://scenes/World/Objects/ObjectiveBox.tscn")
const ANIME_IMPOSTOR = preload("res://scenes/World/Objects/anime_box_sprite.tscn")

@onready var spawn_points : Array[Node2D] = [
	$SpawnLocation1,
	$SpawnLocation2,
	$SpawnLocation3,
	$SpawnLocation4
]
@onready var player_camera : Camera2D = $Camera

func _ready():
	$AnimeBoxHint.visible = false
	var anime : Node2D
	if GameInfos.game_started:
		anime = ANIME_BOX.instantiate()
	else:
		anime = ANIME_IMPOSTOR.instantiate()
		$Music.queue_free()
	anime.position = $AnimeBoxHint.position
	anime.rotation = $AnimeBoxHint.rotation
	add_child(anime)
	$AnimeBoxHint.queue_free()
