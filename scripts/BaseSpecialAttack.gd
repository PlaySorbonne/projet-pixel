extends Node
class_name BaseSpecial

@onready var player : PlayerCharacter = get_parent()

func special():
	print("Special from player " + str(player.character_id) + " ; not yet implemented!")

