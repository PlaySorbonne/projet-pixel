extends Control

signal ButtonStartPressed


func _on_start_button_pressed():
	emit_signal("ButtonStartPressed")
	$StartButton.disabled = true
