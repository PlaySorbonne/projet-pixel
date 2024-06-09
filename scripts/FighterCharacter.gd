extends CharacterBody2D
class_name FighterCharacter

var character_id := 0
var team := 0

static var number_of_characters := 0

static func add_new_character() -> int:
	number_of_characters += 1
	return number_of_characters

static func reset_character_ids() -> void:
	number_of_characters = 0

func _ready():
	print("hullo !")
	character_id = add_new_character()
