extends Node
class_name WrapAround

@export var top_limit    := -500.0:
	set(value):
		top_limit = value
		$SpriteUp.position = Vector2(0, top_limit)
@export var bottom_limit :=  500.0:
	set(value):
		bottom_limit = value
		$SpriteDown.position = Vector2(0, bottom_limit)
@export var left_limit   := -500.0:
	set(value):
		left_limit = value
		$SpriteLeft.position = Vector2(left_limit, 0)
@export var right_limit  :=  500.0:
	set(value):
		right_limit = value
		$SpriteRight.position = Vector2(right_limit, 0)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	for c : Node2D in get_children():
		c.queue_free()
