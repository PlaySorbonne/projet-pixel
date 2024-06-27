extends Control
class_name PlayerPortrait

const PLAYER_PORTRAITS = [
	preload("res://resources/images/champgrumpf.png"),
	preload("res://resources/images/champnaked.png"),
	preload("res://resources/images/characters/Sheep/mouton_portrait.png"),
	preload("res://resources/images/champslay.png"),
	preload("res://sprites/champsu_only.svg")
]

var player_number := 0

func initialize_portrait(player_num : int):
	player_number = player_num
	$TextureBackground.modulate = PlayerCharacter.PLAYER_COLORS[player_num]
	connect_player_object()
	update_health()
	update_evolution()
	var player : PlayerCharacter = GameInfos.players[player_num]
	$LabelName.text = "Player " + str(player_number)

func connect_player_object():
	var player = GameInfos.players[player_number]
	player.fighter_hit.connect(update_health)
	player.player_spawned.connect(update_health)
	player.player_evolved.connect(update_evolution)

func update_health():
	$LabelHealth.text = str(GameInfos.players[player_number].hitpoints
	) + "/" + str(GameInfos.players[player_number].max_hitpoints)

func update_evolution(_evolution = null):
	connect_player_object()
	var new_evolution = GameInfos.players[player_number].current_evolution
	var new_texture = PLAYER_PORTRAITS[new_evolution]
	var new_name : String = PlayerCharacter.Evolutions.keys()[new_evolution]
	$TexturePortrait.texture = new_texture
	$TexturePortraitBackground.texture = new_texture
	$LabelEvolution.text = new_name
	update_health()
