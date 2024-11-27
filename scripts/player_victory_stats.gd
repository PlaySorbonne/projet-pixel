extends VBoxContainer
class_name PlayerVictoryStats



"""
Specific titles:
	victory:
		The No.1 Hero
		Avatar
		I'll be back
		Super Sayen
	
	0 dmg given, 0 kills:
		Luigi
		Zero
	
	most damage inflicted:
		Hokage
	
	never died:
		FullMeta	l
	
	most kills:
		Hero Killer
		Shinigami

Unique titles:
	over 9000 dmg:
		Over 9000
	no dmg received, no death, over 10 kills & 100 dmg & victory:
		The Strongest Man in the World

Random titles:
	Professor Layton
	Pac-Man
	Hero of Time
	Procrastinator
	Darth Weeb
	Dora la Exploradora
	Pirate King
	King of Kongs
"""

func set_player_evolution(current_ev : int):
	str(PlayerCharacter.Evolutions.keys()[current_ev])
	PlayerPortrait.PLAYER_PORTRAITS[current_ev]
