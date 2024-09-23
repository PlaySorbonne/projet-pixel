extends Button

@export var is_current_screen := false:
	set(value):
		if value == is_current_screen:
			return
		is_current_screen = value
		var new_color : Color
		if is_current_screen:
			new_color = Color.GOLD
		else:
			new_color = Color.WHITE
		var tween := create_tween()
		tween.tween_property(self, "modulate", new_color, 0.25)


func _ready():
	$TextureRect.texture = icon

func _tween_scale(new_scale : Vector2):
	var tween := create_tween()
	tween.tween_property(self, "scale", new_scale, 0.2)

func _on_focus_entered():
	_tween_scale(Vector2(1.25, 1.25))

func _on_focus_exited():
	_tween_scale(Vector2.ONE)
