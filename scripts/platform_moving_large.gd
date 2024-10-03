@tool
extends StaticBody2D


@export var next_position := Vector2(0.0, 400.0):
	set(value):
		next_position = value
		$Marker2D.position = value
@export var duration := 5.0

@onready var initial_pos := position
@onready var start_pos := position
@onready var obj_pos := initial_pos + next_position
var forward := true
var timer := 0.0

func _ready():
	if not Engine.is_editor_hint():
		constant_linear_velocity = (obj_pos - start_pos) / duration
	else:
		set_process(false)

func _process(delta : float):
	timer += delta
	position = lerp(start_pos, obj_pos, min(1.0, timer / duration))
	if timer >= duration:
		change()

func change():
	timer = 0.0
	forward = not forward
	if forward:
		start_pos = initial_pos
		obj_pos = initial_pos + next_position
	else:
		start_pos = initial_pos + next_position
		obj_pos = initial_pos
	constant_linear_velocity = (obj_pos - start_pos) / duration
