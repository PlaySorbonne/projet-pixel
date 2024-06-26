extends Area2D

var ready_players: int = 0
var players: int = 0

func _ready():
	update_text()

func _on_body_entered(body: Node2D):
	if body is PlayerCharacter:
		ready_players += 1
		update_text()

func _on_body_exited(body):
	if body is PlayerCharacter:
		ready_players -= 1
		update_text()

func update_text():
	var to_join: int = 2
	if players > 2:
		to_join = players
	$Label.text = "%s/%s joueurs" % [ready_players, to_join]

func _on_player_joined():
	players += 1
	
func _on_player_exited():
	players -= 1
