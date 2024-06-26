extends Node2D

signal StartGame

@export var default_player: PackedScene

var keyboards = []
var controllers = []
var players: Array[PlayerCharacter] = []

var player_joining: bool = false
var current_device = 0
var current_device_type = 0


func _process(delta):
	if player_joining:
		$LoadingBar.scale.x = (1 - $PressKeyTimer.time_left)
	else:
		$LoadingBar.scale.x = 0
	if check_start_game_conditions():
		print("start game")
		start_game()
		
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

func add_player(device, device_type):
	if device_type == 0:
		keyboards.append(device)
	else:
		controllers.append(device)
	var player = default_player.instantiate()
	player.control_device = device
	player.control_type = device_type
	player.compute_hits = false
	players.append(player)
	add_child(player)
	connect_fighter_to_world(player)
	player.spawn($SpawnPoint.position)

func connect_fighter_to_world(body : PlayerCharacter):
	body.fighter_died.connect(on_player_death)
	body.player_evolved.connect(connect_fighter_to_world)

func on_player_death(player : FighterCharacter):
	print("player " + str(player.character_id) + " died !!!")
	await get_tree().create_timer(3.0).timeout
	player.spawn($SpawnPoint.position)

func start_game():
	emit_signal("StartGame", players)

func _on_press_key_timer_timeout():
	add_player(current_device, current_device_type)
	player_joining = false
	
func check_start_game_conditions():
	var ready_start_boxes_nbr: int = 0
	for b in [$StartGameBox1, $StartGameBox2, $StartGameBox3, $StartGameBox4]:
		if b.ready_to_play:
			ready_start_boxes_nbr += 1
	return ready_start_boxes_nbr == len(players)
