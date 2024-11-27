extends Control
class_name PlayerVictoryStats

func shake_node() -> void:
	$Shaker.shake(0.25, 15, 40)

func set_player_evolution(current_ev : int) -> void:
	$Main/LabelEvolution.text = str(PlayerCharacter.Evolutions.keys()[current_ev])
	$Main/TexturePortrait.texture = PlayerPortrait.PLAYER_PORTRAITS[current_ev]

func set_player_titles(common : Array[String], rare : Array[String], 
			legendary : Array[String]) -> void:
	pass
