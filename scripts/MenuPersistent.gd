extends Node2D
class_name Persistent


const LOBBY_PATH = "res://scenes/Menus/GameCreation/game_creation_screen.tscn"
const VAULT_PATH =  "res://scenes/Menus/Vault/VaultPersistent.tscn" 
const WORLD_PATH = "res://scenes/world.tscn"
const TUTORIAL_PATH = "res://scenes/World/Levels/tutorial.tscn"
# previous vault path:  "res://scenes/world.tscn"
const DEFAULT_PLAYER := preload("res://scenes/Characters/Evolutions/ceo_character.tscn")
const TUTORIAL_ENNEMY := preload("res://scenes/Characters/Evolutions/mascot_character.tscn")

enum Screens {Title, Settings, Credits, Vault}

@onready var title_screen := $CanvasLayer/TitleScreen
# @onready var game_session_creator = $CanvasLayer/GameSessionCreator
@onready var lobby := $Lobby
@onready var screen_transition : ScreenTransition = $CanvasLayer/ScreenTransition
var can_change_scene := false

func _ready():
	reset_game_data()
	await get_tree().create_timer(0.5).timeout
	screen_transition.end_screen_transition()
	can_change_scene = true
	$CanvasLayer/TitleScreen.can_input = true

func delay_change_scene(delay : float):
	can_change_scene = false
	await get_tree().create_timer(delay).timeout
	can_change_scene = true

static func reset_game_data():
	GameInfos.use_special_gameplay_data = false
	GlobalVariables.skip_fight_intro = false
	Engine.time_scale = 1.0
	GameInfos.reset_game_infos(true)

func smooth_change_to_scene(new_scene : String):
	if not can_change_scene:
		return
	can_change_scene = true
	var tween := create_tween()
	tween.tween_property($AudioStreamPlayer, "volume_db", -80.0, 0.9)
	await get_tree().create_timer(0.75).timeout
	GameInfos.menu_music_time = $AudioStreamPlayer.get_playback_position()
	screen_transition.start_screen_transition()
	await screen_transition.HalfScreenTransitionFinished
	if get_tree() != null:
		get_tree().change_scene_to_file(new_scene)

func go_to_screen(new_screen : int):
	var title_final_pos : Vector2
	var settings_final_pos : Vector2
	var credits_final_pos : Vector2
	var vault_final_pos : Vector2
	var trans_time := 1.8
	if new_screen == Screens.Title:
		title_final_pos = Vector2.ZERO
		settings_final_pos = Vector2(0.0, 1400.0)
		credits_final_pos = Vector2(0.0, -1400.0)
		vault_final_pos = Vector2(2200, 0.0)
	elif new_screen == Screens.Credits:
		$CanvasLayer/CreditsScreen.emit_signal("screen_focused")
		credits_final_pos = Vector2.ZERO
		title_final_pos = Vector2(0.0, 1400.0)
		settings_final_pos = Vector2(0.0, 1400.0)
		vault_final_pos = Vector2(2200, 0.0)
	elif new_screen == Screens.Vault:
		$CanvasLayer/AchievementScreen.emit_signal("screen_focused")
		title_final_pos = Vector2(-2200, 0.0)
		settings_final_pos = Vector2(0.0, 1400.0)
		credits_final_pos = Vector2(0, -1400)
		vault_final_pos = Vector2.ZERO
	else: # Settings
		$CanvasLayer/SettingsScreen.emit_signal("screen_focused")
		title_final_pos = Vector2(0.0, -1400.0)
		credits_final_pos = Vector2(0.0, -1400.0)
		settings_final_pos = Vector2.ZERO
		vault_final_pos = Vector2(2200, 0.0)
	var t : Tween = get_tree().create_tween().set_trans(Tween.TRANS_ELASTIC)
	t.tween_property($CanvasLayer/TitleScreen, "position", title_final_pos, trans_time)
	t.set_parallel()
	t.tween_property($CanvasLayer/SettingsScreen, "position", settings_final_pos, trans_time)
	t.tween_property($CanvasLayer/CreditsScreen, "position", credits_final_pos, trans_time)
	t.tween_property($CanvasLayer/AchievementScreen, "position", vault_final_pos, trans_time)
	delay_change_scene(trans_time+0.2)

func _on_title_screen_button_start_pressed():
	smooth_change_to_scene(LOBBY_PATH)

func _on_title_screen_button_vault_pressed():
	if not can_change_scene:
		return
	#smooth_change_to_scene(VAULT_PATH)
	go_to_screen(Screens.Vault)

func _on_title_screen_button_settings_pressed():
	go_to_screen(Screens.Settings)

func _on_title_screen_button_credits_pressed():
	go_to_screen(Screens.Credits)
	
func _on_title_screen_button_tutorial_pressed():
	GameInfos.perform_deep_reset()
	if not can_change_scene:
		return
		
	GameInfos.display_end_screen = false
	GameInfos.auto_spawn_players = false
	
	var player : PlayerCharacter = DEFAULT_PLAYER.instantiate()
	var player_index := player.player_ID
	GameInfos.add_player(player)
	
	var ennemy: PlayerCharacter = TUTORIAL_ENNEMY.instantiate()
	GameInfos.add_player(ennemy)
	ennemy.control_device = -1
	
	GameInfos.players_data[ennemy.player_ID]["name"] = "ENNEMY"
	GameInfos.players_data[player.player_ID]["name"] = "PLAYER"
	
	GameInfos.selected_level = 4
	GlobalVariables.skip_fight_intro = true
	smooth_change_to_scene(WORLD_PATH)

func _on_settings_screen_button_back_pressed() -> void:
	back_to_title_screen()

func _on_credits_screen_button_back_pressed() -> void:
	back_to_title_screen()

func _on_achievement_screen_button_back_pressed() -> void:
	back_to_title_screen()

func back_to_title_screen() -> void:
	go_to_screen(Screens.Title)
	$CanvasLayer/TitleScreen.reset_state()

func _on_exit_progress_bar_bar_filled() -> void:
	get_tree().quit()
