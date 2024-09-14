extends Node2D


const LOBBY_PATH = "res://scenes/World/Lobby/Lobby.tscn"
const VAULT_PATH = "res://scenes/world.tscn"
const EXIT_TIME := 1.0

enum Screens {Title, Settings, Credits}

@onready var ExitBar := $CanvasLayer/ExitProgressBar
@onready var title_screen := $CanvasLayer/TitleScreen
# @onready var game_session_creator = $CanvasLayer/GameSessionCreator
@onready var lobby := $Lobby
@onready var screen_transition : ScreenTransition = $CanvasLayer/ScreenTransition

func _ready():
	GameInfos.use_special_gameplay_data = false
	GlobalVariables.skip_fight_intro = false
	GameInfos.reset_game_infos()
	screen_transition.end_screen_transition()
	$TitleScreenDecor/AnimationPlayer.play("idle")
	ExitBar.max_value = EXIT_TIME

func _process(delta : float):
	if Input.is_action_pressed("ui_cancel"):
		ExitBar.visible = true
		ExitBar.value += delta
		if ExitBar.value >= EXIT_TIME:
			get_tree().quit()
	else:
		ExitBar.value = 0.0
		ExitBar.visible = false

func smooth_change_to_scene(new_scene : String):
	await get_tree().create_timer(0.75).timeout
	screen_transition.start_screen_transition()
	await screen_transition.HalfScreenTransitionFinished
	get_tree().change_scene_to_file(new_scene)

func go_to_screen(new_screen : int):
	var title_final_pos : Vector2
	var settings_final_pos : Vector2
	var credits_final_pos : Vector2
	var trans_time := 1.8
	if new_screen == Screens.Title:
		title_final_pos = Vector2.ZERO
		settings_final_pos = Vector2(0.0, 1400.0)
		credits_final_pos = Vector2(0.0, -1400.0)
	elif new_screen == Screens.Credits:
		credits_final_pos = Vector2.ZERO
		title_final_pos = Vector2(0.0, 1400.0)
		settings_final_pos = Vector2(0.0, 1400.0)
	else: # Settings
		title_final_pos = Vector2(0.0, -1400.0)
		credits_final_pos = Vector2(0.0, -1400.0)
		settings_final_pos = Vector2.ZERO
	var t : Tween = get_tree().create_tween().set_trans(Tween.TRANS_ELASTIC)
	t.tween_property($CanvasLayer/TitleScreen, "position", title_final_pos, trans_time)
	t.set_parallel()
	t.tween_property($CanvasLayer/SettingsScreen, "position", settings_final_pos, trans_time)
	t.tween_property($CanvasLayer/CreditsScreen, "position", credits_final_pos, trans_time)

func _on_title_screen_button_start_pressed():
	smooth_change_to_scene(LOBBY_PATH)

func _on_title_screen_button_vault_pressed():
	var player = Lobby.DEFAULT_PLAYER.instantiate()
	GameInfos.level = GameInfos.Levels.StatEditor
	player.control_device = 0
	player.control_type = 0
	player.god_mode = true
	GameInfos.add_player(player)
	smooth_change_to_scene(VAULT_PATH)

func _on_title_screen_button_settings_pressed():
	go_to_screen(Screens.Settings)

func _on_title_screen_button_credits_pressed():
	go_to_screen(Screens.Credits)

func _on_settings_screen_button_back_pressed():
	back_to_title_screen()

func _on_credits_screen_button_back_pressed():
	back_to_title_screen()

func back_to_title_screen():
	go_to_screen(Screens.Title)
	$CanvasLayer/TitleScreen.reset_state()
