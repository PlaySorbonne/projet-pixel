extends Sprite2D
class_name CharacterPointer

@onready var default_pos = position
@onready var parent_character : Node2D = get_parent()

func _ready():
	pass
	# TODO
	# count total health and add how many progress bar you need, 
	# put them on good positions and fill em up real good uwu

# TODO
# also add function to take damage
# maybe something to shake the whole bar when taking damage
# and blink when total is 1 HP (and not weeb ? although weeb 
# constantly blinking might be fun

func _process(_delta):
	global_position = parent_character.global_position + default_pos
