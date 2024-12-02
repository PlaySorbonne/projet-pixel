extends AI_Inputs
class_name AI_InputsWeeb

var cassette : AnimeBox 

@onready var weeb_player : WeebCharacter = get_parent()

func _ready() -> void:
	super._ready()
	await get_tree().create_timer(0.1).timeout
	$TimerChosenEnemy.stop()

func _process(delta: float) -> void:
	cassette = GameInfos.anime_box
	update_enemies(delta, false)
	
	if weeb_player.ascended:
		pass
	else:
		pass
	# attack chosen enemy
	attack_enemy()

func _on_timer_check_ascended_timeout() -> void:
	if not weeb_player.ascended:
		for i : int in enemy_ids:
			var e : PlayerCharacter = GameInfos.players[i]
			if e.has("ascended") and e.ascended:
				chosen_enemy = i
				break
