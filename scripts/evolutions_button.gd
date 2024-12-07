extends Button
# evolution button

func _ready() -> void:
	display_evolve_mode()

func display_evolve_mode() -> void:
	$Label.text = str(GameInfos.EvolvingMode.keys()[GameInfos.evolving_mode])

func _on_pressed() -> void:
	match GameInfos.evolving_mode:
		GameInfos.EvolvingMode.Linear:
			GameInfos.evolving_mode = GameInfos.EvolvingMode.Random
		GameInfos.EvolvingMode.Random:
			GameInfos.evolving_mode = GameInfos.EvolvingMode.Fixed
		GameInfos.EvolvingMode.Fixed:
			GameInfos.evolving_mode = GameInfos.EvolvingMode.Linear
	display_evolve_mode()
