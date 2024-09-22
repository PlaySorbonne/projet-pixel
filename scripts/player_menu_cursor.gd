extends Control
class_name PlayerMenuCursor

const MOV_VELOCITY := 500.0

@export var player_ID := 0:
	set(value):
		player_ID = value
		control_type = GameInfos.players_data[player_ID]["control_type"]
		control_device = GameInfos.players_data[player_ID]["control_device"]
		$TextureRect.modulate = GameInfos.players_data[player_ID]["color"]

var control_type := 0
var control_device := 0
var right_pressed := false
var left_pressed := false
var up_pressed := false
var down_pressed := false

func update_color(new_color : Color):
	$TextureRect.modulate = new_color

func _input(event : InputEvent):
	var is_correct_control_type = false
	if control_type == 0:
		is_correct_control_type = event is InputEventKey
	elif control_type == 1:
		is_correct_control_type = (event is InputEventJoypadButton) or (event is InputEventJoypadMotion)
		
	if is_correct_control_type && event.device == control_device:
		if event.is_action_pressed("right"):
			right_pressed = true
		elif event.is_action_released("right"):
			right_pressed = false
		if event.is_action_pressed("left"):
			left_pressed = true
		elif event.is_action_released("left"):
			left_pressed = false
		if event.is_action_pressed("up"):
			up_pressed = true
		elif event.is_action_released("up"):
			up_pressed = false
		if event.is_action_pressed("down"):
			down_pressed = true
		elif event.is_action_released("down"):
			down_pressed = false
	
		# TODO:
		# add ways to click buttons

func _process(delta : float):
	var velocity := Vector2.ZERO
	if right_pressed:
		velocity.x +=1
	if left_pressed:
		velocity.x -= 1
	if up_pressed:
		velocity.y -= 1
	if down_pressed:
		velocity.y += 1
	position += velocity * MOV_VELOCITY * delta
