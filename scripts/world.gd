extends Node2D
class_name World

const WEEB_EVOLUTION_CROSSHAIR_RES := preload("res://scenes/Utilities/WeebEvolutionCrosshair.tscn")
const LOBBY_PATH = "res://scenes/Menus/GameCreation/game_creation_screen.tscn"
const VICTORY_MESSAGE = preload("res://scenes/Menus/GameUI/victory_message.tscn")

signal game_finished
signal weeb_arrived

@export var victory_audios : Array[AudioStream] = [
	preload("res://resources/audio/voices/narrator/anime_ascend.wav"),
	preload("res://resources/audio/voices/narrator/anime_ascension.wav"),
	preload("res://resources/audio/voices/narrator/anime_unlocked.wav"),
	preload("res://resources/audio/voices/narrator/decorporated.wav"),
	preload("res://resources/audio/voices/narrator/game.wav"),
	preload("res://resources/audio/voices/narrator/game_set.wav"),
	preload("res://resources/audio/voices/narrator/victory.wav"),
	preload("res://resources/audio/voices/narrator/weebtory.wav")
]
@export var weeb_victory_audios : Array[AudioStream] = []

@onready var game_mode : GameMode = $GameMode
var spawn_locations : Array[Node2D]
var player_camera : Camera2D
var player_spawns : Dictionary = {}
var level : Level
var has_weeb_arrived := false
var game_ended := false
var players_left : int = 0
var players_stats : Dictionary = {}
var is_boss_weeb_killed := false

func _ready():
	GameInfos.game_started = true
	level = GameInfos.load_game_level()
	add_child(level)
	spawn_locations = level.spawn_points
	player_camera = level.player_camera
	GameInfos.world = self
	var _hud_objects = $GameHUD.add_players()
	# hide cassette if necessary
	if GameInfos.victory_condition == GameInfos.VictoryConditions.KillBoss:
		await get_tree().process_frame
		GameInfos.anime_box.toggle_cassette(false)
	$CanvasLayer/ScreenTransition.end_screen_transition(2.0)
	await $CanvasLayer/ScreenTransition.ScreenTransitionFinished
	spawn_players()
	if GameInfos.victory_condition == GameInfos.VictoryConditions.KillBoss:
		await get_tree().process_frame
		initialize_boss_weeb()
	players_left = len(GameInfos.players.keys())
	if GlobalVariables.skip_fight_intro:
		activate_players()
	else:
		$StartGameScreen.countdown()
		await $StartGameScreen.countdown_finished
		activate_players()
	# connect eventual timer to end game func
	if GameInfos.gameplay_timer != null and is_instance_valid(GameInfos.gameplay_timer):
		GameInfos.gameplay_timer.timeout.connect(timeout_end_game)

func initialize_boss_weeb() -> void:
	var boss_weeb : WeebCharacter = GameInfos.players[GameInfos.boss_weeb_id]
	boss_weeb.is_super_weeb = true
	boss_weeb.set_ascended_stats(true)
	boss_weeb.global_position = GameInfos.camera.global_position + Vector2(0, -250.0)
	await get_tree().create_timer(2.0).timeout
	GameInfos.anime_box.toggle_cassette(true)
	await get_tree().process_frame
	GameInfos.anime_box.follow_ascended_weeb(boss_weeb)
	boss_weeb.ascend()
	boss_weeb.weeb_descended.connect(boss_weeb_killed)
	for p : PlayerCharacter in GameInfos.players.values():
		if p == boss_weeb:
			p.team = 1
		else:
			p.team = 0

func boss_weeb_killed(_boss_weeb : WeebCharacter) -> void:
	is_boss_weeb_killed = true
	end_game()

func timeout_end_game() -> void:
	end_game()

func choose_tmp_winners() -> void:
	var winners : Array[int] = []
	match GameInfos.victory_condition:
		GameInfos.VictoryConditions.Elimination:
			# tmp winner is most advanced evolution
			var best_evol := PlayerCharacter.Evolutions.CEO
			for p : PlayerCharacter in GameInfos.players.values():
				if p.ascended:
					winners = [p.player_ID]
					break
				elif p.current_evolution > best_evol:
					best_evol = p.current_evolution
					winners = [p.player_ID]
				elif p.current_evolution == best_evol:
					winners = []
		GameInfos.VictoryConditions.Kills:
			# winner(s) is(are) player(s) with the most killsé
			var max_kills := 0
			for p_stats : PlayerStats in players_stats.values():
				if p_stats.kills > max_kills:
					winners = [p_stats.player_id]
					max_kills = p_stats.kills
				elif p_stats.kills == max_kills and max_kills>0:
					winners.append(p_stats.player_id)
		GameInfos.VictoryConditions.CassetteTime:
			var max_time := 0.0
			for p_stats : PlayerStats in players_stats.values():
				var p : PlayerCharacter = GameInfos.players[p_stats.player_id]
				if p.has_method("get_time_ascended") and p.get_time_ascended() > max_time:
					winners = [p_stats.player_id]
					max_time = p.get_time_ascended()
		GameInfos.VictoryConditions.KillBoss:
			if is_boss_weeb_killed:
				for i : int in GameInfos.players.keys():
					if i != GameInfos.boss_weeb_id:
						winners.append(i)
			else:
				winners = [GameInfos.boss_weeb_id]
	GameInfos.tmp_winners = winners

func choose_winners() -> void:
	var winners : Array[int] = []
	match GameInfos.victory_condition:
		GameInfos.VictoryConditions.Elimination:
			# winner are last standing players
			for p : PlayerCharacter in GameInfos.players.values():
				if not p.is_eliminated:
					winners.append(p.player_ID)
		GameInfos.VictoryConditions.Kills:
			# winner(s) is(are) player(s) with the most killsé
			var max_kills := 0
			for p_stats : PlayerStats in players_stats.values():
				var p : PlayerCharacter = GameInfos.players[p_stats.player_id]
				if not p.is_eliminated:
					if p_stats.kills > max_kills:
						winners = [p_stats.player_id]
					elif p_stats.kills == max_kills:
						winners.append(p_stats.player_id)
		GameInfos.VictoryConditions.CassetteTime:
			var max_time := 0.0
			for p_stats : PlayerStats in players_stats.values():
				var p : PlayerCharacter = GameInfos.players[p_stats.player_id]
				if not p.is_eliminated and (p.has_method("get_time_ascended")
								) and p.get_time_ascended() > max_time:
					max_time = p.get_time_ascended()
					winners = [p.player_ID]
		GameInfos.VictoryConditions.KillBoss:
			if is_boss_weeb_killed:
				for i : int in GameInfos.players.keys():
					if i != GameInfos.boss_weeb_id:
						winners.append(i)
			else:
				winners = [GameInfos.boss_weeb_id]
	GameInfos.last_winners = winners

func player_eliminated():
	players_left -= 1
	if players_left <= 1:
		end_game()

func end_game():
	if game_ended:
		return
	game_ended = true
	choose_winners()
	var victory_label : Label = $CanvasLayer/EndScreen/LabelVictoryText/LabelVictoryPlayer
	var win_text := ""
	victory_label.text = ""
	for win_id : int in GameInfos.last_winners:
		if victory_label.text.length() > 0:
			victory_label.text += ", "
		victory_label.text += GameInfos.players_data[win_id]["name"]
	$GameHUD/PauseMenu.can_pause_game = false
	$AudioWeebVictory.stream = weeb_victory_audios.pick_random()
	$AudioWeebVictory.play()
	GameInfos.freeze_frame.slow_mo(0.1, 1.0)
	var music_node : AudioStreamPlayer = level.get_node("Music")
	create_tween().tween_property(music_node, "volume_db", -80.0, 1.5)
	await get_tree().create_timer(1.0, true, false, true).timeout
	var victory_message := VICTORY_MESSAGE.instantiate()
	add_child(victory_message)
	for p : PlayerCharacter in GameInfos.players.values():
		p.set_player_active(false)
	GameInfos.camera_utils.shake(0.5, 15, 50, 2)
	GameInfos.camera_utils.interp_zoom(player_camera.zoom + Vector2(0.1, 0.1), 0.15)
	await get_tree().create_timer(0.8, true, false, true).timeout
	$AudioVictory.stream = victory_audios.pick_random()
	$AudioVictory.play()
	emit_signal("game_finished")
	if not GameInfos.display_end_screen:
		return
	
	
	get_tree().paused = true
	await get_tree().create_timer(0.5).timeout
	
	$GameHUD.remove_portraits()
	for p : PlayerCharacter in GameInfos.players.values():
		if p.alive:
			break
	$CanvasLayer/EndScreen.init_end_screen(players_stats)
	await $CanvasLayer/EndScreen.end_game_finished
	
	VaultData.save_vault_data()
	get_tree().paused = false
	Engine.time_scale = 1.0
	$CanvasLayer/ScreenTransition.start_screen_transition(2.0)
	await $CanvasLayer/ScreenTransition.HalfScreenTransitionFinished
	get_tree().change_scene_to_file(LOBBY_PATH)

func activate_players():
	if GameInfos.time_limit > 0:
		GameInfos.gameplay_timer.start_timer()
	players_stats = {}
	for player : PlayerCharacter in GameInfos.players.values():
		player.set_player_active(true)
		var p_stats : PlayerStats = PlayerStats.new()
		players_stats[player.player_ID] = p_stats
		p_stats.player_id = player.player_ID
		p_stats.player_name = GameInfos.players_data[player.player_ID]["name"]
		p_stats.current_evolution = player.current_evolution
		player.player_stats = p_stats

func spawn_players():
	var player_number = 0
	for player : PlayerCharacter in GameInfos.players.values():
		player_spawns[player.player_ID] = spawn_locations[player_number].position
		if GameInfos.auto_spawn_players:
			add_child(player)
			player.spawn(player_spawns[player.player_ID], false)
		connect_fighter_to_world(player)
		player_number += 1
		GameInfos.tracked_targets.append(player)

func connect_fighter_to_world(body : PlayerCharacter):
	body.fighter_died.connect(on_player_death)
	body.player_evolved.connect(connect_fighter_to_world)
	body.damage_given.connect(on_player_given_damage)
	body.damage_taken.connect(on_player_taken_damage)
	body.player_kill.connect(on_player_kill.bind(body))
	GameInfos.camera.add_target(body)
	if body.current_evolution == PlayerCharacter.Evolutions.Weeb:
		weeb_arrival(body)

func weeb_arrival(new_weeb : WeebCharacter):
	if not has_weeb_arrived:
		has_weeb_arrived = true
		GameInfos.camera_utils.flash_constrast(1.05, 0.25, false)
	var crosshair := WEEB_EVOLUTION_CROSSHAIR_RES.instantiate()
	level.set_music_pitch(1.05)
	new_weeb.connect("weeb_ascended", weeb_ascension)
	new_weeb.connect("weeb_descended", weeb_descension)
	emit_signal("weeb_arrived")
	crosshair.followed_actor = new_weeb
	add_child(crosshair)
	GameInfos.camera_utils.shake()

func weeb_ascension(weeb : PlayerCharacter):
	const PROJECTION_VELOCITY := 12000.0
	GameInfos.camera_utils.shake()
	GameInfos.camera_utils.flash_constrast(1.15, 0.25, false)
	GameInfos.freeze_frame.slow_mo(0.1, 0.3)
	var current_zoom : Vector2 = GameInfos.camera.zoom
	GameInfos.camera_utils.interp_zoom(current_zoom * 1.05, 0.2)
	for p : PlayerCharacter in GameInfos.players.values():
		if p.alive and p != weeb:
			var dir : Vector2 = weeb.position.direction_to(p.position)
			p.knockback_velocity = dir * PROJECTION_VELOCITY
	await get_tree().create_timer(0.2).timeout
	GameInfos.camera_utils.interp_zoom(current_zoom, 0.1)

func weeb_descension(weeb : PlayerCharacter) -> void:
	GameInfos.camera_utils.shake()
	GameInfos.camera_utils.flash_constrast(1.05, 0.25, false)

func _process(_delta) -> void:
	if Input.is_action_just_pressed("pause_game"):
		$GameHUD/PauseMenu.enter_pause()

func get_p_stats(player : PlayerCharacter) -> PlayerStats:
	return players_stats[player.player_ID]

func on_player_taken_damage(player : PlayerCharacter, damage : int) -> void:
	get_p_stats(player).damage_received += damage

func on_player_given_damage(player : PlayerCharacter, damage : int) -> void:
	get_p_stats(player).damage_given += damage

func on_player_kill(player : PlayerCharacter) -> void:
	get_p_stats(player).kills += 1

func on_player_death(player : PlayerCharacter) -> void:
	get_p_stats(player).deaths += 1
	await get_tree().create_timer(game_mode.respawn_time).timeout
	player.spawn(player_spawns[player.player_ID])

func _on_timer_check_winners_timeout() -> void:
	choose_tmp_winners()
