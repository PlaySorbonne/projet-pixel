extends Area2D

func interact(player: PlayerCharacter):
	player.evolve(true)
	#print(player.current_evolution)
