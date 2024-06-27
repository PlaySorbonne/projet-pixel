extends Node

var game_started := false
var world : Node2D
var camera : Camera2D
var camera_utils : CameraUtils
var freeze_frame : FreezeFrame
var players : Dictionary = {}
var players_order : Array[int] = []
var player_colors : Array[int] = []
var number_of_players = 0
var last_used_id = 0


func reset_game_infos() -> void:
	game_started = false
	players = {}
	player_colors = []
	number_of_players = 0
	last_used_id = 0
	
func add_player(player: PlayerCharacter) -> void:
	var id = player.player_ID
	players[id] = player
	number_of_players += 1
	
func remove_player(player: PlayerCharacter) -> void:
	var id = player.player_ID
	number_of_players -= 1
	players.erase(id)
	compute_character_ids()

func compute_character_ids() -> void:
	var id = 1
	for player: PlayerCharacter in players.values():
		player.character_id = id
		id += 1
		player._update_debug_text()

# add stats (damage, kills, deaths, time in the air, time on the ground, distance, 
# accuracy, evolution...)


# add battle type (team, brawl, etc)
