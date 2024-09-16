extends Node
class_name BaseSpecial

@onready var player : PlayerCharacter = get_parent()
@onready var sprite_effect : CharacterSpriteEffect = player.get_node("SpriteEffect")
var can_use_special := true : 
	set(value):
		sprite_effect.set_special_availability(value)
		can_use_special = value

func special():
	print("Special from player " + str(player.player_ID) + " ; not yet implemented!")
