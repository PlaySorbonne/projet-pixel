extends Control
class_name GameCreationScreen

const LEVEL_OBJ_POS := Vector2(3000.0, 0.0)
const PLAYER_INFOS_RES := preload("res://scenes/Menus/GameCreation/PlayerSelection.tscn")
const PLAYER_INFOS_POS_OFFSET := Vector2(35.0, 75.0)
const PLAYER_INFOS_POS_INIT := Vector2(50.0, 100.0)
const DEFAULT_PLAYER := preload("res://scenes/Characters/Evolutions/ceo_character.tscn")
const WORLD_PATH := "res://scenes/world.tscn"
const AUDIO_PITCH_DEFAULT := 1.0
const AUDIO_PITCH_INTENSE := 1.0

@export var transition : ScreenTransition
@export var level_parent : SubViewport

@onready var music_tester := $ButtonTestMusic/AudioTestMusic
@onready var music_background := $AudioStreamPlayer
var music_tester_music := -1
var keyboards: Array[int] = []
var controllers: Array[int] = []
var player_selectors : Array[PlayerSelection] = []
var current_level : Level = null
var level_selected := -1
var are_evolutions_selectable := false

func _ready():
	$AudioStreamPlayer.play(GameInfos.menu_music_time)
	GameInfos.menu_music_time = 0.0
	GameInfos.reset_game_infos()
	set_game_widgets()
	$LabelMoney/AnimationPlayer.play("idle")
	$LabelMoney.text = GameInfos.format_money_string(VaultData.vault_data["money"])
	transition.end_screen_transition()
	var t := create_tween().set_trans(Tween.TRANS_CUBIC).set_loops()
	var def_pos : Vector2 = $ButtonAddAI.position
	t.tween_property($ButtonAddAI, "position", def_pos + Vector2(0.0, -15.0), 0.3)
	t.tween_property($ButtonAddAI, "position", def_pos, 0.5)
	if GameInfos.players_data.keys().size() != 0:
		reload_old_game_infos()
		$AudioStreamPlayer.pitch_scale = AUDIO_PITCH_INTENSE
		if len(GameInfos.players_data.keys()) >= 2:
			$ButtonConfirm/AnimationStart.play("idle")
			$ButtonConfirm.disabled = false
	else:
		$AudioStreamPlayer.pitch_scale = AUDIO_PITCH_DEFAULT
		$ButtonConfirm/AnimationStart.play("leave")
		$ButtonConfirm.disabled = true

func _process(_delta):
	if Input.is_action_just_pressed("pause_game"):
		$ButtonConfirm.play_sound()
		_on_button_confirm_pressed()

func set_game_widgets():
	$GameModeSelector.selected_option = GameInfos.victory_condition
	$LevelSelector.options = GameInfos.LEVEL_TITLES
	$LevelSelector.selected_option = 0
	$MusicSelector.options = GameInfos.MUSIC_NAMES
	$MusicSelector.selected_option = 0
	set_gamemode(GameInfos.selected_gamemode)
	set_music(GameInfos.selected_music)
	set_level(GameInfos.selected_level)

func reload_old_game_infos():
	var delay := 0.0
	for id: int in GameInfos.players_data.keys():
		var player : PlayerCharacter = DEFAULT_PLAYER.instantiate()
		player.player_ID = id
		var p_controlled : bool = GameInfos.players_data[id]["player_controlled"]
		player.is_player_controlled = p_controlled
		if p_controlled:
			var control_device : int = GameInfos.players_data[id]["control_device"]
			var control_type : int = GameInfos.players_data[id]["control_type"]
			player.control_device = control_device
			player.control_type = control_type
			if control_type == 0:
				keyboards.append(control_device)
			else:
				controllers.append(control_device)
		else:
			player.ai_difficulty = GameInfos.players_data[id]["ai_difficulty"]
		GameInfos.players[id] = player
		create_player_infos(id, delay, false)
		delay += 0.5

func create_player_infos(index : int, delay := 0.0, with_voice := true):
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	var player_infos : PlayerSelection = PLAYER_INFOS_RES.instantiate()
	$PlayersContainer.add_child(player_infos)
	player_selectors.append(player_infos)
	if GameInfos.victory_condition != GameInfos.VictoryConditions.KillBoss or (
														len(player_selectors) > 1):
		player_infos.set_can_select_evolution(are_evolutions_selectable)
	check_start_button()
	player_infos.with_voice = with_voice
	player_infos.player_index = index
	player_infos.last_winner = (GameInfos.last_winners.has(index))
	var player : PlayerCharacter = GameInfos.players[index]
	if player.is_player_controlled:
		player_infos.control_type = GameInfos.players_data[index]["control_type"]
		player_infos.control_index = GameInfos.players_data[index]["control_device"]
	player_infos.position = PLAYER_INFOS_POS_INIT + PLAYER_INFOS_POS_OFFSET*(
		player_selectors.size()-1)
	player_infos.connect("player_removed", remove_player)

func check_start_button():
	var not_active = $ButtonConfirm.disabled
	if not_active and len(player_selectors) >= 2:
		$AudioStreamPlayer.pitch_scale = AUDIO_PITCH_INTENSE
		$ButtonConfirm/AnimationStart.play("start")
		$ButtonConfirm.disabled = false
	elif not(not_active) and len(player_selectors) < 2:
		$ButtonConfirm/AnimationStart.play_backwards("start_leave")
		$ButtonConfirm.disabled = true
		$AudioStreamPlayer.pitch_scale = AUDIO_PITCH_DEFAULT

func add_player(device_type : int, device : int):
	var player : PlayerCharacter = DEFAULT_PLAYER.instantiate()
	var player_index := player.player_ID
	player.control_device = device
	player.control_type = device_type
	GameInfos.add_player(player)
	create_player_infos(player_index)

func _unhandled_input(event : InputEvent):
	if len(player_selectors) == 4:
		return
	if event is InputEventKey:
		if event.device not in keyboards:
			if event.is_pressed():
				keyboards.append(event.device)
				add_player(0, event.device)
	elif event is InputEventJoypadButton:
		if event.device not in controllers:
			if event.is_pressed():
				controllers.append(event.device)
				add_player(1, event.device)

func set_test_music(test_music : bool):
	if test_music:
		music_background.stream_paused = true
		if music_tester_music != GameInfos.selected_music:
			music_tester.stream = load(GameInfos.MUSICS_PATHS[GameInfos.selected_music])
			music_tester.play()
		music_tester.stream_paused = false
	else:
		music_background.stream_paused = false
		music_tester.stream_paused = true

func _on_button_test_music_pressed():
	set_test_music(not music_tester.playing)

func _on_music_selector_option_changed(new_option : int):
	set_test_music(false)
	GameInfos.selected_music = new_option
	set_music(new_option)

func set_music(music : int):
	$ButtonTestMusic.text = GameInfos.MUSIC_NAMES[music]
	GameInfos.selected_music = music

func _on_game_mode_selector_option_changed(new_option : int):
	GameInfos.selected_gamemode = new_option
	set_gamemode(new_option)

var is_first_player_exalted := false
func set_gamemode(gamemode : int):
	#$LabelGameModeName.text = GameInfos.GAME_MODE_TITLES[gamemode]
	$LabelGameModeDescription.text = GameInfos.GAME_MODE_DESCRIPTIONS[gamemode]
	GameInfos.victory_condition = gamemode
	if GameInfos.victory_condition != GameInfos.VictoryConditions.KillBoss:
		if len(player_selectors) > 0:
			player_selectors[0].set_exalted(false)
			is_first_player_exalted = false
	
	match GameInfos.victory_condition:
		GameInfos.VictoryConditions.Elimination:
			$EvolutionsButton.set_can_change_evolving_mode(true)
			$StatsButton.set_stats_mode(GameInfos.StatsFiles.Linear)
			$TimeButton.set_forced_time(false)
			
		GameInfos.VictoryConditions.Kills:
			$EvolutionsButton.set_can_change_evolving_mode(true)
			$TimeButton.set_forced_time(false)
			
		GameInfos.VictoryConditions.CassetteTime:
			$EvolutionsButton.set_evolving_mode(GameInfos.EvolvingMode.Fixed)
			$EvolutionsButton.set_can_change_evolving_mode(false)
			force_player_evolution(PlayerCharacter.Evolutions.Weeb)
			set_selectable_evolutions(false)
			$TimeButton.set_forced_time(true)
			
		GameInfos.VictoryConditions.KillBoss:
			$EvolutionsButton.set_evolving_mode(GameInfos.EvolvingMode.Fixed)
			$EvolutionsButton.set_can_change_evolving_mode(false)
			$StatsButton.set_stats_mode(GameInfos.StatsFiles.Balanced)
			$TimeButton.set_forced_time(false)
			is_first_player_exalted = true
			if len(player_selectors) > 0:
				player_selectors[0].set_exalted(true)

func _on_level_selector_option_changed(new_option : int):
	GameInfos.selected_level = new_option
	set_level(new_option)

func set_level(level : int):
	if level == level_selected:
		return
	level_selected = level
	var sub_viewport = $TextureLevel/SubViewport
	if current_level != null:
		current_level.queue_free()
	current_level = load(GameInfos.LEVEL_PATHS[level]).instantiate()
	current_level.position = Vector2(25.0, 25.0)
	current_level.scale = Vector2(0.2, 0.2)
	sub_viewport.add_child(current_level)

func remove_player(selector : PlayerSelection, _index : int):
	var pos_in_array := player_selectors.find(selector)
	var duration := 0.3
	var tween := create_tween().set_parallel()
	if selector.control_type:
		controllers.erase(selector.control_index)
	else:
		keyboards.erase(selector.control_index)
	for i in range(pos_in_array+1, player_selectors.size()):
		var s : PlayerSelection = player_selectors[i]
		tween.tween_property(s, "position", s.position - PLAYER_INFOS_POS_OFFSET, duration)
		duration += 0.2
	player_selectors.remove_at(pos_in_array)
	check_start_button()

var default_evolution := PlayerCharacter.Evolutions.CEO
func force_player_evolution(ev : PlayerCharacter.Evolutions) -> void:
	default_evolution = ev
	for ps : PlayerSelection in player_selectors:
		ps.set_player_evolution(default_evolution)

func set_selectable_evolutions(ev_selectable : bool) -> void:
	are_evolutions_selectable = ev_selectable
	if len(player_selectors) == 0:
		return
	var i : int = 0
	if GameInfos.victory_condition == GameInfos.VictoryConditions.KillBoss: 
		i = 1
	while i < player_selectors.size():
		player_selectors[i].set_can_select_evolution(ev_selectable)
		i += 1

func set_first_player_weeb() -> void:
	if len(player_selectors) == 0:
		return
	player_selectors[0].set_player_evolution(PlayerCharacter.Evolutions.Weeb)

func _on_animation_start_animation_finished(anim_name : String):
	if anim_name == "start" and not($ButtonConfirm.disabled):
		$ButtonConfirm/AnimationStart.play("idle")

var start_pressed := false
func _on_button_confirm_pressed():
	if len(player_selectors) < 2 or start_pressed:
		return
	start_pressed = true
	create_tween().tween_property($AudioStreamPlayer, "volume_db", -80.0, 0.25)
	$AudioNarratorStart.play()
	$Shaker.shake(0.4, 20, 40, 1)
	$ButtonConfirm/AnimationStart.play("start_game")
	await $ButtonConfirm/AnimationStart.animation_finished
	#transition.start_screen_transition()
	#await transition.HalfScreenTransitionFinished
	get_tree().change_scene_to_file(WORLD_PATH)

func _on_button_back_pressed():
	transition.start_screen_transition()
	await transition.HalfScreenTransitionFinished
	get_tree().change_scene_to_file("res://scenes/Menus/MenuPersistent.tscn")

@onready var default_ai_button_rot = $ButtonAddAI.rotation
var can_add_ai := true
func _on_button_add_ai_pressed() -> void:
	if len(player_selectors) == 4 or not can_add_ai:
		return
	can_add_ai = false
	var player : PlayerCharacter = DEFAULT_PLAYER.instantiate()
	player.is_player_controlled = false
	var player_index := player.player_ID
	player.control_device = -1
	player.control_type = -1
	GameInfos.add_player(player)
	create_player_infos(player_index)
	var t := create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel()
	$ButtonAddAI.rotation = default_ai_button_rot
	t.tween_property($ButtonAddAI, "scale", Vector2(1.5, 1.5), 0.2)
	t.tween_property($ButtonAddAI, "rotation", default_ai_button_rot+2*PI, 0.5)
	await get_tree().create_timer(0.2).timeout
	var t2 := create_tween().set_trans(Tween.TRANS_CUBIC)
	t2.tween_property($ButtonAddAI, "scale", Vector2.ONE, 0.3)
	can_add_ai = true

func _on_button_add_ai_mouse_entered() -> void:
	var t := create_tween().set_trans(Tween.TRANS_CUBIC)
	t.tween_property($ButtonAddAI, "modulate", Color.RED, 0.5)

func _on_button_add_ai_mouse_exited() -> void:
	var t := create_tween().set_trans(Tween.TRANS_CUBIC)
	t.tween_property($ButtonAddAI, "modulate", Color.WHITE, 0.5)
