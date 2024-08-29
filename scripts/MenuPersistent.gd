extends Node2D


const LOBBY_PATH = "res://scenes/World/Lobby/Lobby.tscn"
const VAULT_PATH = "res://scenes/world.tscn"
const CREDITS_PATH = "res://scenes/Menus/intro_screen.tscn"


@onready var title_screen = $CanvasLayer/TitleScreen
# @onready var game_session_creator = $CanvasLayer/GameSessionCreator
@onready var lobby = $Lobby
@onready var screen_transition : ScreenTransition = $CanvasLayer/ScreenTransition

func _ready():
	GameInfos.reset_game_infos()
	screen_transition.end_screen_transition()
	$TitleScreenDecor/AnimationPlayer.play("idle")

func smooth_change_to_scene(new_scene : String):
	get_tree().create_timer(0.75).timeout
	screen_transition.start_screen_transition()
	await screen_transition.HalfScreenTransitionFinished
	get_tree().change_scene_to_file(new_scene)

func _on_title_screen_button_start_pressed():
	smooth_change_to_scene(LOBBY_PATH)

func _on_title_screen_button_vault_pressed():
	var player = Lobby.DEFAULT_PLAYER.instantiate()
	player.control_device = 0
	player.control_type = 0
	player.god_mode = true
	GameInfos.add_player(player)
	smooth_change_to_scene(VAULT_PATH)

func _on_title_screen_button_settings_pressed():
	pass # Replace with function body.

func _on_title_screen_button_credits_pressed():
	smooth_change_to_scene(CREDITS_PATH)
