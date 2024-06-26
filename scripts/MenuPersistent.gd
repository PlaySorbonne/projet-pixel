extends Node2D

@export var level_scene: PackedScene
@onready var title_screen = $CanvasLayer/TitleScreen
# @onready var game_session_creator = $CanvasLayer/GameSessionCreator
@onready var lobby = $Lobby
var screen_transition : ScreenTransition


func _ready():
	GameInfos.reset_game_infos()
	screen_transition = $CanvasLayer/ScreenTransition
	screen_transition.end_screen_transition()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

func _on_title_screen_button_start_pressed():
	screen_transition.new_screen_transition()
	await screen_transition.HalfScreenTransitionFinished
	title_screen.visible = false
	lobby.visible = true

func _on_lobby_start_game():
	var level = level_scene.instantiate()
	screen_transition.start_screen_transition()
	await screen_transition.HalfScreenTransitionFinished
	get_tree().change_scene_to_packed(level_scene)
