extends XYZ_Button

func _ready():
	var p : Control = get_parent()
	p.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

func _on_pressed():
	var p : Control = get_parent()
	var tween := create_tween()
	tween.tween_property(p, "modulate", Color.TRANSPARENT, 0.3)
	await tween.finished
	get_tree().paused = false
	p.queue_free()
