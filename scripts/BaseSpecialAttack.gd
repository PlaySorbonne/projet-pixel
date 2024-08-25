extends Node
class_name BaseSpecial

@onready var player : PlayerCharacter = get_parent()
var can_use_special := true

func special():
	print("Special from player " + str(player.player_ID) + " ; not yet implemented!")
