extends Node2D

const LOBBY_PATH = "res://scenes/World/Lobby/Lobby.tscn"
const VICTORY_MESSAGE = preload("res://scenes/Menus/GameUI/victory_message.tscn")

@onready var spawn_locations : Array = [
	$SpawnLocation1,
	$SpawnLocation2,
	$SpawnLocation3,
	$SpawnLocation4
]

var player_spawns = {}

func _testing_function():
	var freezeframe : FreezeFrame = $Camera/FreezeFrame
	var screenshake : CameraUtils = $Camera/CameraUtils
	while true:
		await get_tree().create_timer(2.0).timeout
		#freezeframe.freeze()
		screenshake.shake()

func _ready():
	#_testing_function()
	GameInfos.game_started = true
	GameInfos.world = self
	var hud_objects = $GameHUD.add_players()
	$CanvasLayer/ScreenTransition.end_screen_transition(2.0)
	await $CanvasLayer/ScreenTransition.ScreenTransitionFinished
	spawn_players()
	if GlobalVariables.skip_fight_intro:
		activate_players()
	else:
		$StartGameScreen.countdown()
		await $StartGameScreen.countdown_finished
		activate_players()

func end_game():
	for p : PlayerCharacter in GameInfos.players:
		p.set_player_active(false)
	add_child(VICTORY_MESSAGE.instantiate())
	GameInfos.camera_utils.shake(0.5, 15, 50, 2)
	GameInfos.camera_utils.interp_zoom($Camera.zoom + Vector2(0.1, 0.1), 0.15)
	await get_tree().create_timer(1.5).timeout
	$CanvasLayer/ScreenTransition.start_screen_transition(2.0)
	await $CanvasLayer/ScreenTransition.HalfScreenTransitionFinished
	get_tree().change_scene_to_file(LOBBY_PATH)

func activate_players():
	for player : PlayerCharacter in GameInfos.players:
		player.set_player_active(true)

func spawn_players():
	var player_number = 0
	for player : PlayerCharacter in GameInfos.players:
		add_child(player)
		connect_fighter_to_world(player)
		player_spawns[player.player_ID] = spawn_locations[player_number].position
		player.spawn(player_spawns[player.player_ID], false)
		player_number += 1

func connect_fighter_to_world(body : PlayerCharacter):
	body.fighter_died.connect(on_player_death)
	body.player_evolved.connect(connect_fighter_to_world)

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func on_player_death(player : FighterCharacter):
	await get_tree().create_timer(3.0).timeout
	player.spawn(player_spawns[player.player_ID])
