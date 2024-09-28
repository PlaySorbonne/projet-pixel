extends Node2D
class_name World

const WEEB_EVOLUTION_CROSSHAIR_RES := preload("res://scenes/Utilities/WeebEvolutionCrosshair.tscn")
const LOBBY_PATH = "res://scenes/Menus/GameCreation/game_creation_screen.tscn"
const VICTORY_MESSAGE = preload("res://scenes/Menus/GameUI/victory_message.tscn")

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

func _ready():
	GameInfos.game_started = true
	level = GameInfos.load_game_level()
	add_child(level)
	spawn_locations = level.spawn_points
	player_camera = level.player_camera
	GameInfos.world = self
	var _hud_objects = $GameHUD.add_players()
	$CanvasLayer/ScreenTransition.end_screen_transition(2.0)
	await $CanvasLayer/ScreenTransition.ScreenTransitionFinished
	spawn_players()
	players_left = len(GameInfos.players.keys())
	if GlobalVariables.skip_fight_intro:
		activate_players()
	else:
		$StartGameScreen.countdown()
		await $StartGameScreen.countdown_finished
		activate_players()

func add_level():
	pass

func player_eliminated():
	players_left -= 1
	if players_left <= 1:
		end_game()

func end_game():
	if game_ended:
		return
	game_ended = true
	$AudioWeebVictory.stream = weeb_victory_audios.pick_random()
	$AudioWeebVictory.play()
	GameInfos.freeze_frame.slow_mo(0.1, 1.0)
	var music_node : AudioStreamPlayer = level.get_node("Music")
	create_tween().tween_property(music_node, "volume_db", -80.0, 1.5)
	await get_tree().create_timer(1.0, true, false, true).timeout
	add_child(VICTORY_MESSAGE.instantiate())
	for p : PlayerCharacter in GameInfos.players.values():
		p.set_player_active(false)
	GameInfos.camera_utils.shake(0.5, 15, 50, 2)
	GameInfos.camera_utils.interp_zoom(player_camera.zoom + Vector2(0.1, 0.1), 0.15)
	await get_tree().create_timer(1.0, true, false, true).timeout
	$AudioVictory.stream = victory_audios.pick_random()
	$AudioVictory.play()
	await get_tree().create_timer(3.5, true, false, true).timeout
	$CanvasLayer/ScreenTransition.start_screen_transition(2.0)
	await $CanvasLayer/ScreenTransition.HalfScreenTransitionFinished
	get_tree().change_scene_to_file(LOBBY_PATH)

func activate_players():
	for player : PlayerCharacter in GameInfos.players.values():
		player.set_player_active(true)

func spawn_players():
	var player_number = 0
	for player : PlayerCharacter in GameInfos.players.values():
		add_child(player)
		connect_fighter_to_world(player)
		player_spawns[player.player_ID] = spawn_locations[player_number].position
		player.spawn(player_spawns[player.player_ID], false)
		player_number += 1
		GameInfos.tracked_targets.append(player)

func connect_fighter_to_world(body : PlayerCharacter):
	body.fighter_died.connect(on_player_death)
	body.player_evolved.connect(connect_fighter_to_world)
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
	for p : PlayerCharacter in GameInfos.players.values():
		if p.alive and p != weeb:
			var dir : Vector2 = weeb.position.direction_to(p.position)
			p.knockback_velocity = dir * PROJECTION_VELOCITY

func weeb_descension(weeb : PlayerCharacter):
	GameInfos.camera_utils.shake()
	GameInfos.camera_utils.flash_constrast(1.05, 0.25, false)

func _process(_delta):
	if Input.is_action_just_pressed("pause_game"):
		$GameHUD/PauseMenu.enter_pause()

func on_player_death(player : FighterCharacter):
	await get_tree().create_timer(game_mode.respawn_time).timeout
	player.spawn(player_spawns[player.player_ID])
