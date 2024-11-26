extends VBoxContainer
class_name PlayerVictoryStats


func set_player_evolution(current_ev : int):
	str(PlayerCharacter.Evolutions.keys()[current_ev])
	PlayerPortrait.PLAYER_PORTRAITS[current_ev]
