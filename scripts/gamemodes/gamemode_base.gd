extends Node
class_name BattleGameMode

@export var intial_evolution : PlayerCharacter.Evolutions = PlayerCharacter.Evolutions.CEO
@export var use_unique_stats_file := false
@export var unique_stats_file : String = ""

func select_gamemode() -> void:
	return

func start_game() -> void:
	pass
