extends Button
# lives button


func _ready() -> void:
	if GameInfos.lives_limit > 0:
		$ButtonCancel.visible = true
		text = str(GameInfos.lives_limit)

func _on_pressed() -> void:
	if GameInfos.lives_limit < 0:
		pass
	else:
		pass

func _on_spin_combo_click_down() -> void:
	pass # Replace with function body.

func _on_spin_combo_click_up() -> void:
	pass # Replace with function body.

func _on_button_cancel_pressed() -> void:
	pass # Replace with function body.
