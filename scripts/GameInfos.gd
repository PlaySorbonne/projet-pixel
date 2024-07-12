extends Node

var game_started := false
var world : Node2D
var camera : Camera2D
var camera_utils : CameraUtils
var freeze_frame : FreezeFrame
var players : Array[PlayerCharacter] = []
var players_order : Array[int] = []
var player_colors : Array[Color] = []
var number_of_players = 0
var last_used_id = -1


func reset_game_infos() -> void:
	game_started = false
	players = []
	player_colors = []
	number_of_players = 0
	last_used_id = -1

func add_player(player: PlayerCharacter) -> void:
	players.append(player)
	player_colors.append(available_colors()[0])
	number_of_players += 1
	
func remove_player(player: PlayerCharacter) -> void:
	var id = player.player_ID
	number_of_players -= 1
	players.erase(id)
	player_colors.erase(id)
	compute_ids()

func compute_ids() -> void:
	for i in range(len(players)):
		players[i].player_ID = i
		players[i]._update_debug_text()
		
func available_colors() -> Array:
	var colors = PlayerCharacter.PLAYER_COLORS.filter(func(c): return not c in player_colors)
	print(colors)
	return colors
	
func change_color(player_id: int) -> void:
	player_colors[player_id] = available_colors()[0]

# add stats (damage, kills, deaths, time in the air, time on the ground, distance, 
# accuracy, evolution...)


# add battle type (team, brawl, etc)
