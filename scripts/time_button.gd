extends Button
# TimeButton


func _ready() -> void:
	if GameInfos.time_limit > 0:
		display_time_as_text()

func display_time_as_text() -> void:
	var minutes := int(GameInfos.time_limit/60)
	$Label.text = str(minutes) + ":" + str(GameInfos.time_limit % 60).pad_zeros(2)

func _on_spin_combo_click_down() -> void:
	if GameInfos.time_limit < 0:
		GameInfos.time_limit = 90
	else:
		GameInfos.time_limit = max(30, GameInfos.time_limit-30)
	display_time_as_text()

func _on_spin_combo_click_up() -> void:
	if GameInfos.time_limit < 0:
		GameInfos.time_limit = 120
	else:
		GameInfos.time_limit = min(600, GameInfos.time_limit+30)
	display_time_as_text()

func _on_button_cancel_pressed() -> void:
	GameInfos.time_limit = -1
	$ButtonCancel.visible = false
	$Label.text = "No_limit"
