extends Node2D

@export var level_scene: PackedScene
@onready var title_screen = $CanvasLayer/TitleScreen
@onready var game_session_creator = $CanvasLayer/GameSessionCreator
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
	game_session_creator.visible = true

func _on_game_session_creator_start_game(players):
	var level = level_scene.instantiate()
	GameInfos.players = players
	screen_transition.start_screen_transition()
	await screen_transition.HalfScreenTransitionFinished
	get_tree().change_scene_to_packed(level_scene)
