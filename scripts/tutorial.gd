extends "res://scripts/level_template.gd"

const DEFAULT_PLAYER := preload("res://scenes/Characters/Evolutions/ceo_character.tscn")

var has_pressed_key: bool = false
var player_id: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameInfos.perform_deep_reset()
	var player : PlayerCharacter = DEFAULT_PLAYER.instantiate()
	player_id = player.player_ID
	player.position = $SpawnLocation1.position
	GameInfos.add_player(player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event : InputEvent):
	if not has_pressed_key:
		if event is InputEventKey:
			GameInfos.players[player_id].set_control_type(0)
		elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
			GameInfos.players[player_id].set_control_type(1)
		GameInfos.players[player_id].set_control_device(event.device)
		has_pressed_key = true
	
