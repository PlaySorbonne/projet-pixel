extends Control

signal StartGame

@export var player_scene: PackedScene

var keyboards = []
var controllers = []
var players = []

func _input(event):
	if event is InputEventKey:
		if event.device not in keyboards:
			keyboards.append(event.device)
			var player = player_scene.instantiate()
			player.control_device = event.device
			player.control_type = 0
			players.append(player)
			$JoinedPlayers.text += "Player" + str(len(players)) + "(keyboard)\n"
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if event.device not in controllers:
			controllers.append(event.device)
			var player = player_scene.instantiate()
			player.control_device = event.device
			player.control_type = 1
			players.append(player)
			$JoinedPlayers.text += "Player" + str(len(players)) + "(controller)\n"
	if len(players) > 0:
		$Button.disabled = false

func _on_button_pressed():
	emit_signal("StartGame", players)
	$Button.disabled = true
