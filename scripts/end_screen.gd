extends Control
class_name EndScreen

signal end_game_finished

const LABEL_END_SCREEN_RES := preload("res://scenes/Menus/GameUI/label_player_end_screen.tscn")
const TROPHY_RES := preload("res://scenes/Menus/GameCreation/last_winner.tscn")


const COMMON_TITLES : Array[String] = [
	"No.1 Weeb",
	"The Chosen One",
	"I'll be back",
	"Super Sayen",
	"Luigi Numbah 2",
	"Waluigi time",
	"Zero",
	"Hokage",
	"Fullmetal Weeb",
	"Hero Killer",
	"Professor Layton",
	"Hero of Time",
	"Procrastinator",
	"Darth Weeb",
	"Pirate King",
	"Weebborn",
	"Dom Slayer",
	"Chocoboss",
	"Overcaffeinated CEO",
	"Respawn Lord",
	"Yeeted",
	"Red Shell",
	"Electric Fox",
	"Shonen Spirit",
	"Kung Fu Buffalo",
	"AFK King",
	"Beta Tester",
	"Button Masher",
	"Joystick Rider",
	"Critical Failer",
	"Energy Drinker",
	"4chan user",
	"Cosplayer",
]

const RARE_TITLES : Array[String] = [
	"Over 9000",
	"Dora la Exploradora",
	"King of Kongs",
	"The Tarnished",
	"Biggest Chocobo",
	"The Chicken Whisperer",
	"Grass-Cutting Champion",
	"Pokemon Master",
	"Min-Maxer",
	"Linux Overlord",
	"Taco Master",
	"Hero of Rhyme",
	"Memelord",
	"Scary Shiny Glasses",
	"Hentai Anthropologist",
	"The Strongest Man in the World",
]

const LEGENDARY_TITLES : Array[String] = [
	"World Champion",
	"Anilinkz Completionist",
	"Supreme Commander",
	"Decorporater",
	"Ascended", 
]

var is_end_game := false
var current_end_step := 1
var end_finished := false

@onready var player_stats_node : GridContainer = $PlayerStats

func _ready() -> void:
	set_process(false)
	visible = false
	print("WORLD -> CANVASLAYER -> END_SCREEN: REMEMBER TO HIDE END_SCREEN")
	print("AND SHOW SCREEN_TRANSITION")
	print("AND SET END_SCREEN PROCESS TO WHEN_PAUSED")

func init_player_titles(player_ids : Array[int], winner_id : int) -> Dictionary:
	const TITLES := [COMMON_TITLES, RARE_TITLES, LEGENDARY_TITLES]
	const TITLES_TOTAL_TRIES := [24, 12, 1]
	const TITLES_CHANCE := [0.75, 0.4, 0.4]
	const TITLES_EFFECTS := [
		
	]
	var player_titles : Dictionary = {}
	var nb_players : int = len(player_ids)
	for id : int in player_ids:
		player_titles[id] = {}
	for i : int in range(TITLES.size()):
		var current_titles : Array[String] = TITLES[i]
		current_titles.shuffle()
		var selected_titles : Array[String] = []
		for _j : int in range(max(1, TITLES_TOTAL_TRIES[i]/4)):
			if randf() < TITLES_CHANCE[i]:
				selected_titles.append(current_titles.pop_back())
		if len(selected_titles) == 1:
			player_titles[winner_id][selected_titles[0]] = i
		elif len(selected_titles) > 1:
			for t : String in selected_titles:
				player_titles[player_ids.pick_random()][t] = i
	# returns a dictionary of :
	#	{key=player_id : value={key=title : value=rarity}}
	return player_titles

func init_end_screen(winner_id : int, players_stats : Dictionary) -> void:
	is_end_game = true
	set_process(true)
	var is_first_winner_node := true
	var arr_stats : Array[PlayerStats] = [players_stats[winner_id]]
	# random titles we give to each player
	var given_titles : Dictionary = init_player_titles(GameInfos.players.keys(), winner_id)
	for p_stats : PlayerStats in players_stats.values():
		p_stats.set_death_based_on_winner(winner_id)
		if p_stats.player_id != winner_id:
			arr_stats.append(p_stats)
	for p_stats : PlayerStats in arr_stats:
		for s : String in p_stats.get_stats_as_array():
			var l : Label = LABEL_END_SCREEN_RES.instantiate()
			l.text = s
			player_stats_node.add_child(l)
			if is_first_winner_node:
				is_first_winner_node = false
				var trophy : Control = TROPHY_RES.instantiate()
				l.add_child(trophy)
				trophy.position = Vector2(-150, -50)
				trophy.declare_winner()
	$AnimationEndSteps.play("end_enter")
	visible = true

func _process(delta: float) -> void:
	if not is_end_game:
		return
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("special"):
		current_end_step += 1
		execute_current_step()
		
	elif Input.is_action_just_pressed("attack"):
		current_end_step = max(0, current_end_step-1)
		execute_current_step(false)

func execute_current_step(forward := true):
	match current_end_step:
		0:
			$AnimationEndSteps.play_backwards("end_enter")
		1:
			if forward:
				$AnimationEndSteps.play("end_enter", -1, 1.0, false)
			else:
				$AnimationEndSteps.play_backwards("end_stats")
		2:
			$AnimationEndSteps.play("end_stats", -1, 1.0, false)
		3:
			emit_signal("end_game_finished")
