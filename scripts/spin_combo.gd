extends Control
class_name SpinCombo

signal click_up
signal click_down


func _on_button_up_pressed() -> void:
	emit_signal("click_up")

func _on_button_down_pressed() -> void:
	emit_signal("click_down")
