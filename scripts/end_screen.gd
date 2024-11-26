extends Control
class_name EndScreen

const LABEL_END_SCREEN_RES := preload("res://scenes/Menus/GameUI/label_player_end_screen.tscn")

var is_end_game := false
var current_end_step := 0

@onready var player_stats_node : GridContainer = $PlayerStats

func _ready() -> void:
	set_process(false)
	print("WORLD -> CANVASLAYER -> END_SCREEN: REMEMBER TO HIDE END_SCREEN")
	print("AND SHOW SCREEN_TRANSITION")
	print("AND SET END_SCREEN PROCESS TO WHEN_PAUSED")

func init_end_screen(winner_id : int, players_stats : Dictionary) -> void:
	is_end_game = true
	set_process(true)
	var arr_stats : Array[PlayerStats] = [players_stats[winner_id]]
	for p_stats : PlayerStats in players_stats:
		p_stats.set_death_based_on_winner(winner_id)
		if p_stats.player_id != winner_id:
			arr_stats.append(p_stats)
	for p_stats : PlayerStats in arr_stats:
		for s : String in p_stats.get_stats_as_array():
			var l : Label = LABEL_END_SCREEN_RES.instantiate()
			l.text = p_stats.s
			player_stats_node.add_child(l)
		

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("special"):
		current_end_step += 1
	elif Input.is_action_just_pressed("attack"):
		current_end_step -= 1
