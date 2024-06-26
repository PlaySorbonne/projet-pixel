extends Control
class_name PlayerPortrait


func initialize_portrait(player_num : int):
	$TextureBackground.modulate = PlayerCharacter.PLAYER_COLORS[player_num]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
