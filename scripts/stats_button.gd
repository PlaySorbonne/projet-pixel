extends Button
# stats button

@onready var game_creation_screen : GameCreationScreen = get_parent()


func _ready() -> void:
	display_stats()

func display_stats() -> void:
	$Label.text = str(GameInfos.StatsFiles.keys()[GameInfos.stats_file])

func set_can_change_stats_file(can_change : bool) -> void:
	disabled = not can_change
	if can_change:
		$Label.modulate = Color.WHITE
	else:
		$Label.modulate = Color.GRAY

func set_stats_mode(stats : GameInfos.StatsFiles) -> void:
	GameInfos.stats_file = stats
	display_stats()
	SettingsScreen.update_stats_file(stats)

func _on_pressed() -> void:
	match GameInfos.stats_file:
		GameInfos.StatsFiles.Linear:
			set_stats_mode(GameInfos.StatsFiles.Balanced)
		GameInfos.StatsFiles.Balanced:
			set_stats_mode(GameInfos.StatsFiles.Custom)
		GameInfos.StatsFiles.Custom:
			set_stats_mode(GameInfos.StatsFiles.Linear)
