extends Area2D

var ready_to_play: bool = false

func _on_body_entered(body: Node2D):
	print("test")
	if body is PlayerCharacter:
		# Mettre des données en plus au joueur ici (par exemple sa courleur)
		ready_to_play = true
		print("test")
		$Label.text = "Prêt"

func _on_body_exited(body):
	if body is PlayerCharacter:
		# Enlever les données ajoutées
		ready_to_play = true
		$Label.text = ""



