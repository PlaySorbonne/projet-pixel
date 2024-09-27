extends XYZ_Button

func _ready():
	var p : Control = get_parent()
	p.process_mode = Node.PROCESS_MODE_ALWAYS
	Vault.music_player.volume_db = -20
	get_tree().paused = true
	grab_focus()

func _on_pressed():
	var p : Control = get_parent()
	var tween := create_tween()
	tween.tween_property(p, "modulate", Color.TRANSPARENT, 0.3)
	await tween.finished
	get_tree().paused = false
	Vault.vault_focused_object.grab_focus()
	Vault.music_player.volume_db = 0
	p.queue_free()
