extends VBoxContainer
class_name PlayerVictoryStats

"""
Specific titles:
	Hokage: most damage inflicted
	Pirate King: 
	Luigi: did nothing
	Super Sayen: longest time as ascended weeb

Random titles:
	G


"""

func set_player_evolution(current_ev : int):
	str(PlayerCharacter.Evolutions.keys()[current_ev])
	PlayerPortrait.PLAYER_PORTRAITS[current_ev]
