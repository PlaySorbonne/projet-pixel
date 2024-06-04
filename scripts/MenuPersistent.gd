extends Node2D


@onready var title_screen = $CanvasLayer/TitleScreen
@onready var game_session_creator = $CanvasLayer/GameSessionCreator
var screen_transition : ScreenTransition


func _ready():
	screen_transition = $CanvasLayer/ScreenTransition

func _on_title_screen_button_start_pressed():
	screen_transition.new_screen_transition()
	await screen_transition.HalfScreenTransitionFinished
	title_screen.visible = false
	game_session_creator.visible = true

func _on_game_session_creator_start_game():
	screen_transition.start_screen_transition()
	await screen_transition.HalfScreenTransitionFinished
	get_tree().change_scene_to_file("res://scenes/world.tscn")
