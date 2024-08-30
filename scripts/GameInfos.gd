extends Node

enum Levels {Default, Training, StatEditor}
const LEVEL_PATHS = {
	Levels.Default : "res://scenes/World/Levels/level_default.tscn",
	Levels.Training : "res://scenes/World/Levels/level_training.tscn",
	Levels.StatEditor : "res://scenes/World/Levels/level_stat_editor.tscn"
}

var game_started := false
var world : Node2D
var level := Levels.Default
var camera : Camera2D
var camera_utils : CameraUtils
var freeze_frame : FreezeFrame
var players : Array[PlayerCharacter] = []
var players_order : Array[int] = []
var player_colors : Array[Color] = []
var available_colors_index := 0

func reset_game_infos() -> void:
	game_started = false
	players = []
	players_order = []
	player_colors = []
	available_colors_index = 0
	level = Levels.Default

func load_game_level() -> Level:
	return load(LEVEL_PATHS[level]).instantiate()

func add_player(player: PlayerCharacter) -> void:
	players.append(player)
	player_colors.append(available_colors()[0])
	
func remove_player(player: PlayerCharacter) -> void:
	var id = player.player_ID
	print(players)
	players.remove_at(id)
	player_colors.remove_at(id)
	compute_ids()

func compute_ids() -> void:
	for i in range(len(players)):
		players[i].player_ID = i
		players[i]._update_debug_text()
		
func available_colors() -> Array:
	return PlayerCharacter.PLAYER_COLORS.filter(func(c): return not c in player_colors)
	
func change_color(player_id: int) -> void:
	var available_colors = available_colors()
	player_colors[player_id] = available_colors[available_colors_index]
	available_colors_index += 1
	if available_colors_index == len(available_colors):
		available_colors_index = 0

func players_number(): return len(players)

# add stats (damage, kills, deaths, time in the air, time on the ground, distance, 
# accuracy, evolution...)


# add battle type (team, brawl, etc)
