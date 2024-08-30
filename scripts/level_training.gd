extends Level


func _on_button_back_pressed():
	get_tree().change_scene_to_file("res://scenes/Menus/MenuPersistent.tscn")
