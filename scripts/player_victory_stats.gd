extends Control
class_name PlayerVictoryStats


func set_player_evolution(current_ev : int):
	str(PlayerCharacter.Evolutions.keys()[current_ev])
	PlayerPortrait.PLAYER_PORTRAITS[current_ev]

func set_player_titles(common : Array[String], rare : Array[String], 
			legendary : Array[String]) -> void:
	pass
