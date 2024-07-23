extends Area2D

func interact(player: PlayerCharacter):
	GameInfos.change_color(player.player_ID)
	player.set_player_color(GameInfos.player_colors[player.player_ID])
