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
@onready var background_parent : Node2D = $Background

func _ready():
	$AnimeBoxHint.visible = false
	var anime : Node2D
	if GameInfos.game_started:
		anime = ANIME_BOX.instantiate()
		$Music.stream = load(GameInfos.MUSICS_PATHS[GameInfos.selected_music])
		$Music.play(0.0)
	else:
		anime = ANIME_IMPOSTOR.instantiate()
		$Music.queue_free()
	anime.position = $AnimeBoxHint.position
	anime.rotation = $AnimeBoxHint.rotation
	add_child(anime)
	$AnimeBoxHint.queue_free()

func level_background_death_fx(zoom_pos : Vector2):
	const DURATION := 0.85
	GameInfos.camera_utils.quick_zoom(1.2, zoom_pos, 0.6, 0.1)
	var t := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(background_parent, "modulate", Color.BLACK, 0.05)
	await get_tree().create_timer(0.85, true, false, true)
	t.tween_property(background_parent, "modulate", Color.WHITE, 0.4)

func set_music_pitch(new_pitch : float):
	$Music.pitch_scale = new_pitch
