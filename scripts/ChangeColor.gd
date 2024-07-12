extends Area2D

var queue: Array[int] = []

func _init():
	pass
	# update_label()

func interract(player: PlayerCharacter):
	if len(queue) > 0 and queue[0] == player.player_ID:
		GameInfos.change_color(player.player_ID)
		update_label()

func update_label():
	if len(queue) == 0:
		$Label.text = ""
	else:
		var selected_player = queue[0]
		$Label.text = "Joueur " + str(selected_player + 1) + " : " + str(GameInfos.player_colors[selected_player])

func _on_body_entered(body):
	if body is PlayerCharacter:
		queue.push_back(body.player_ID)
		update_label()


func _on_body_exited(body):
	if body is PlayerCharacter:
		queue.erase(body.player_ID)
		update_label()
