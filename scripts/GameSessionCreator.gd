extends Control

signal StartGame


func _on_button_pressed():
	emit_signal("StartGame")
	$Button.disabled = true
