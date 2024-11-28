extends Control
class_name EndScreen

signal end_game_finished

const LABEL_END_SCREEN_RES := preload("res://scenes/Menus/player_victory_stats.tscn")
# preload("res://scenes/Menus/GameUI/label_player_end_screen.tscn")
const TROPHY_RES := preload("res://scenes/Menus/GameCreation/last_winner.tscn")


const COMMON_TITLES : Array[String] = [
	"No.1 Weeb",
	"The Chosen One",
	"I'll be back",
	"Super Saiyan",
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
var are_stats_initialized := false
var player_stats_nodes : Array[PlayerVictoryStats] = []

@onready var player_stats_node : HBoxContainer = $PlayerStats

func _ready() -> void:
	set_process(false)
	visible = false
	print("WORLD -> CANVASLAYER -> END_SCREEN: REMEMBER TO HIDE END_SCREEN")
	print("AND SHOW SCREEN_TRANSITION")
	print("AND SET END_SCREEN PROCESS TO WHEN_PAUSED")

func init_player_titles(player_ids : Array, winner_id : int) -> Dictionary:
	const TITLES := [LEGENDARY_TITLES, RARE_TITLES, COMMON_TITLES]
	const TITLES_TOTAL_TRIES := [0.5, 10, 21]
	const TITLES_CHANCE := [1.0, 0.4, 0.5]
	const RARITIES := ["legendary", "rare", "common"]
	const MAX_TITLES_PER_PLAYER := 5
	# initialize stuff
	var player_titles : Dictionary = {}
	var nb_players : int = len(player_ids)
	var players_nb_titles : Dictionary = {}
	for id : int in player_ids:
		player_titles[id] = {
			RARITIES[0] : [],
			RARITIES[1] : [],
			RARITIES[2] : []
		}
		players_nb_titles[id] = 0
	# generate and distribute titles
	for i : int in range(TITLES.size()):
		var current_titles : Array[String] = TITLES[i].duplicate()
		current_titles.shuffle()
		# select titles to distribute
		var selected_titles : Array[String] = []
		for _j : int in range(max(1, int((TITLES_TOTAL_TRIES[i]/4.0)*len(player_ids)) )):
			var rand_val := randf()
			if rand_val < TITLES_CHANCE[i]:
				var new_title : String = current_titles.pop_back()
				selected_titles.append(new_title)
		# give legendary title to winner
		if i == 0 and len(selected_titles) == 1:
			player_titles[winner_id][RARITIES[0]].append(selected_titles[0])
			players_nb_titles[winner_id] += 1
		# distribute common and rare titles
		elif len(selected_titles) > 1:
			for t : String in selected_titles:
				if len(player_ids) == 0:
					break
				var current_id : int = player_ids.pick_random()
				player_titles[current_id][RARITIES[i]].append(t)
				players_nb_titles[current_id] += 1
				if players_nb_titles[current_id] >= MAX_TITLES_PER_PLAYER:
					player_ids.erase(current_id)
	# returns a dictionary of the titles given to each player:
	#	{key=player_id : value={key=title : value=rarity}}
	return player_titles

func init_end_screen(players_stats : Dictionary) -> void:
	var winner_id := GameInfos.last_winner
	is_end_game = true
	set_process(true)
	var arr_stats : Array[PlayerStats] = [players_stats[winner_id]]
	# random titles we give to each player
	var given_titles : Dictionary = init_player_titles(
					players_stats.keys().duplicate(), winner_id)
	for p_stats : PlayerStats in players_stats.values():
		p_stats.set_death_based_on_winner(winner_id)
		if p_stats.player_id != winner_id:
			arr_stats.append(p_stats)
	# create and add nodes to display player stats and titles
	for p_stats : PlayerStats in arr_stats:
		var l : PlayerVictoryStats = LABEL_END_SCREEN_RES.instantiate()
		player_stats_node.add_child(l)
		l.set_player_stats(p_stats)
		# transfer titles data to node
		var common_titles : Array = given_titles[p_stats.player_id]["common"]
		var rare_titles : Array = given_titles[p_stats.player_id]["rare"]
		var legendary_titles : Array = given_titles[p_stats.player_id]["legendary"]
		l.set_player_titles(common_titles, rare_titles, legendary_titles)
		# display trophy is current player won
		if p_stats.player_id == winner_id:
			l.declare_winner()
		player_stats_nodes.append(l)
	$AnimationEndSteps.play("end_enter")
	await get_tree().process_frame
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
			if not are_stats_initialized:
				are_stats_initialized = true
				await $AnimationEndSteps.animation_finished
				for l : PlayerVictoryStats in player_stats_nodes:
					l.intro_animation()
					await get_tree().create_timer(0.5).timeout
		3:
			emit_signal("end_game_finished")
