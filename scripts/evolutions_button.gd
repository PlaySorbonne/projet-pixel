extends Button
# evolution button

@onready var game_creation_screen : GameCreationScreen = get_parent()


func _ready() -> void:
	display_evolve_mode()

func display_evolve_mode() -> void:
	$Label.text = str(GameInfos.EvolvingMode.keys()[GameInfos.evolving_mode])

func _on_pressed() -> void:
	match GameInfos.evolving_mode:
		GameInfos.EvolvingMode.Linear:
			GameInfos.evolving_mode = GameInfos.EvolvingMode.Random
			game_creation_screen.set_selectable_evolutions(true, true)
		GameInfos.EvolvingMode.Random:
			GameInfos.evolving_mode = GameInfos.EvolvingMode.Fixed
			game_creation_screen.set_selectable_evolutions(true, true)
		GameInfos.EvolvingMode.Fixed:
			GameInfos.evolving_mode = GameInfos.EvolvingMode.Linear
			game_creation_screen.set_selectable_evolutions(false)
	display_evolve_mode()
