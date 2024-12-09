extends Button
# evolution button

@onready var game_creation_screen : GameCreationScreen = get_parent()


func _ready() -> void:
	display_evolve_mode()

func display_evolve_mode() -> void:
	$Label.text = str(GameInfos.EvolvingMode.keys()[GameInfos.evolving_mode])

func set_can_change_evolving_mode(can_change : bool) -> void:
	disabled = not can_change
	if can_change:
		$Label.modulate = Color.WHITE
	else:
		$Label.modulate = Color.GRAY

func set_evolving_mode(ev_mode : GameInfos.EvolvingMode) -> void:
	GameInfos.evolving_mode = ev_mode
	game_creation_screen.set_selectable_evolutions(ev_mode != GameInfos.EvolvingMode.Fixed)
	display_evolve_mode()

func _on_pressed() -> void:
	match GameInfos.evolving_mode:
		GameInfos.EvolvingMode.Linear:
			set_evolving_mode(GameInfos.EvolvingMode.Random)
		GameInfos.EvolvingMode.Random:
			set_evolving_mode(GameInfos.EvolvingMode.Fixed)
		GameInfos.EvolvingMode.Fixed:
			set_evolving_mode(GameInfos.EvolvingMode.Linear)
