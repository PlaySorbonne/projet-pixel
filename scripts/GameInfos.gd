extends Node

var game_started := false
var world : Node2D
var camera : Camera2D
var camera_utils : CameraUtils
var freeze_frame : FreezeFrame
var players : Array = []
var players_order : Array = []
var player_colors : Array = []
var number_of_players = 0


func reset_game_infos():
	game_started = false
	players = []
	player_colors = []
	number_of_players = 0
	
func add_player(default_player: PackedScene):
	

# add stats (damage, kills, deaths, time in the air, time on the ground, distance, 
# accuracy, evolution...)


# add battle type (team, brawl, etc)
