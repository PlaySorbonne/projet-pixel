extends Node2D

signal StartGame
signal PlayerJoined
signal PlayerExited

@export var default_player: PackedScene

@onready var initial_time_left = $PressKeyTimer.wait_time
var keyboards: Array[int] = []
var controllers: Array[int] = []
var player_joining: bool = false
var current_device: int = 0
var current_device_type: int = 0

var ready_players_count: int = 0

func _process(delta):
	if player_joining:
		$LoadingBar.scale.x = (initial_time_left - $PressKeyTimer.time_left) / initial_time_left
	else:
		$LoadingBar.scale.x = 0

func _input(event):
	if event is InputEventKey:
		if event.device not in keyboards:
			if event.is_pressed() and not player_joining:
				player_joining = true
				current_device = event.device
				current_device_type = 0
				$PressKeyTimer.start()
			if event.is_released():
				player_joining = false
				$PressKeyTimer.stop()
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if event.device not in controllers:
			if event.is_pressed() and not player_joining:
				player_joining = true
				current_device = event.device
				current_device_type = 1
				$PressKeyTimer.start()
			if event.is_released():
				player_joining = false
				$PressKeyTimer.stop()

func add_player(device: int, device_type: int):
	if device_type == 0:
		keyboards.append(device)
	else:
		controllers.append(device)
	var player = default_player.instantiate()
	player.control_device = device
	player.control_type = device_type
	player.compute_hits = false
	GameInfos.add_player(player)
	
	add_child(player)
	connect_fighter_to_world(player)
	player.spawn($SpawnPoint.position)
	PlayerJoined.emit()

func connect_fighter_to_world(body : PlayerCharacter):
	body.fighter_died.connect(on_player_death)
	body.player_evolved.connect(connect_fighter_to_world)

func on_player_death(player : FighterCharacter):
	await get_tree().create_timer(3.0).timeout
	player.spawn($SpawnPoint.position)

func start_game():
	emit_signal("StartGame")

func _on_press_key_timer_timeout():
	add_player(current_device, current_device_type)
	player_joining = false


func check_start_game_conditions():
	var ready_start_boxes_nbr: int = 0
	for b in [$StartGameBox1, $StartGameBox2, $StartGameBox3, $StartGameBox4]:
		if b.ready_to_play:
			ready_start_boxes_nbr += 1
	return ready_start_boxes_nbr == len(GameInfos.players.values()) and ready_start_boxes_nbr != 0

func _on_start_game_box_body_entered(body):
	if not body.is_in_group("player"): # check if thassaplayer
		return
	ready_players_count += 1
	if ready_players_count == len(GameInfos.players.values()) and ready_players_count > 1:
		remove_players()
		start_game()

func _on_start_game_box_body_exited(body: Node2D):
	if not body.is_in_group("player"): # check if thassaplayer
		return
	ready_players_count -= 1

func remove_players():
	for p : PlayerCharacter in GameInfos.players.values():
		p.remove_player()
		remove_child(p)
		
func remove_player(player: PlayerCharacter):
	if player.control_type == 0:
		keyboards.erase(player.control_device)
	else:
		controllers.erase(player.control_device)
	GameInfos.remove_player(player)
	remove_child(player)

func _on_exit_zone_body_entered(body: Node2D):
	if body is PlayerCharacter:
		remove_player(body)
		
