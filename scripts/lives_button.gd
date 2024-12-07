extends Button
# lives button


func _ready() -> void:
	if GameInfos.lives_limit > 0:
		$ButtonCancel.visible = true
		display_lives()

func display_lives() -> void:
	text = str(GameInfos.lives_limit)

func _on_pressed() -> void:
	if GameInfos.lives_limit < 0:
		_on_spin_combo_click_up()
	else:
		_on_button_cancel_pressed()

func _on_spin_combo_click_down() -> void:
	if GameInfos.lives_limit < 0:
		GameInfos.lives_limit = 9
	else:
		GameInfos.lives_limit = max(GameInfos.lives_limit-1, 1)
	display_lives()

func _on_spin_combo_click_up() -> void:
	if GameInfos.lives_limit < 0:
		GameInfos.lives_limit = 5
	else:
		GameInfos.lives_limit = min(GameInfos.lives_limit+1, 99)
	display_lives()

func _on_button_cancel_pressed() -> void:
	$ButtonCancel.visible = false
	GameInfos.lives_limit = -1
	text = "No_limit"
