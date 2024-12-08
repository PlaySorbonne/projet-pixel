extends AI_Inputs
class_name AI_InputsWeeb

const MIN_DIST_SPECIAL := pow(25.0, 2.0)
const MIN_DIST_DIRECTIONAL := 25.0

var cassette : AnimeBox 

@onready var weeb_player : WeebCharacter = get_parent()

func _process(delta: float) -> void:
	update_enemies(delta, false)
	_on_timer_chosen_enemy_timeout()
	if weeb_player.ascended:
		# if ascended, attack random enemy
		attack_enemy()
		# implement dash use in movement
		if time_since_special > time_between_specials:
			use_special(enemies[chosen_enemy].global_position)
	else:
		# if not ascended, attack cassette or enemy holding cassette
		attack_cassette()
		# implement dash use in movement
		if time_since_special > time_between_specials:
			use_special(special_enemy.global_position)

func use_special(target_location : Vector2) -> void:
	var location = player.global_position
	if location.distance_squared_to(target_location) > MIN_DIST_SPECIAL:
		var dash_dir : Vector2 = (target_location - location)
		if dash_dir.x > MIN_DIST_DIRECTIONAL:
			player_tap_direction(Directions.Right)
		elif dash_dir.x < -MIN_DIST_DIRECTIONAL:
			player_tap_direction(Directions.Left)
		if dash_dir.y > MIN_DIST_DIRECTIONAL / 2.0:
			player_tap_direction(Directions.Down)
		elif dash_dir.y < -MIN_DIST_DIRECTIONAL / 2.0:
			player_tap_direction(Directions.Up)
		player_special()
