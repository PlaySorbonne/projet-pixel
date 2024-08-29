extends Control
class_name SettingsScreen

signal ButtonBackPressed


func _on_button_back_pressed():
	$ButtonBack.release_focus()
	emit_signal("ButtonBackPressed")
