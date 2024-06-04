extends Node2D

@export var player_scene: PackedScene

var keyboards = []
var controllers = []
var screen_transition : ScreenTransition

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_transition = $CanvasLayer/ScreenTransition
	screen_transition.end_screen_transition()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventKey:
		if event.device not in keyboards:
			keyboards.append(event.device)
			var player = player_scene.instantiate()
			player.control_device = event.device
			player.control_type = 0
			player.position = $SpawnLocation.position
			add_child(player)
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if event.device not in controllers:
			controllers.append(event.device)
			var player = player_scene.instantiate()
			player.control_device = event.device
			player.control_type = 1
			player.position = $SpawnLocation.position
			add_child(player)
