extends Resource
class_name PlayerStats

var player_id := -1
var player_name := "zob"

var kills := 0
var deaths := 0
var damage_given := 0
var damage_received := 0
var current_evolution := -1

func set_deaths_based_on_winners() -> void:
	if not GameInfos.players[player_id].alive:
		deaths += 1

func get_stats_as_array() -> Array[String]:
	var p : PlayerCharacter = GameInfos.players[player_id]
	return [player_name, str(damage_given), str(damage_received), str(kills), str(deaths), 
			str(PlayerCharacter.Evolutions.keys()[p.current_evolution])]
