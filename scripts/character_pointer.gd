extends Sprite2D
class_name CharacterPointer

@onready var default_pos = position
@onready var parent_character : Node2D = get_parent()

func _process(_delta):
	global_position = parent_character.global_position + default_pos
