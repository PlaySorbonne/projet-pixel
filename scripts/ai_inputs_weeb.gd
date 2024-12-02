extends AI_Inputs
class_name AI_InputsWeeb

var cassette : AnimeBox 

@onready var weeb_player : WeebCharacter = get_parent()

func _process(delta: float) -> void:
	# implement dash use in movement
	cassette = GameInfos.anime_box
	
	
	
	
	update_enemies(delta, false)
	_on_timer_chosen_enemy_timeout()
	if weeb_player.ascended:
		# if ascended, attack random enemy
		attack_enemy()
	else:
		# if not ascended, attack cassette or enemy holding cassette
		attack_cassette()
