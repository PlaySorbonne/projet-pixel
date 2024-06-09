extends CharacterBody2D
class_name FighterCharacter

@export var max_hitpoints := 3
@export var invincibility_time := 0.2

var character_id := 0
var team := 0
var facing_right := true
var hitpoints := max_hitpoints

static var number_of_characters := 0

static func add_new_character() -> int:
	number_of_characters += 1
	return number_of_characters

static func reset_character_ids() -> void:
	number_of_characters = 0

func _ready():
	print("hullo !")
	character_id = add_new_character()
	team = character_id # to remove if we decide to do team battles

func hit(damage : int):
	hitpoints -= damage
	if hitpoints < 0:
		pass
	#print("fighter " + str(character_id) + " got hit : " + str(hitpoints) + "/" + str(max_hitpoints))
