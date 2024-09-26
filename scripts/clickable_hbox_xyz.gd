extends HBoxContainer
class_name XYZ_ClickableHBox

signal pressed

@onready var focused : bool = has_focus()

func _ready():
	self.connect("focus_entered", add_focus)
	self.connect("focus_exited", remove_focus)

func add_focus():
	focused = true
	tween_color_to(Color.AQUA)

func tween_color_to(color : Color) -> Tween:
	var tween := create_tween()
	tween.tween_property(self, "modulate", color, 0.2)
	return tween

func remove_focus():
	focused = false
	tween_color_to(Color.WHITE)

func _process(_delta : float):
	if focused and Input.is_action_just_pressed("ui_accept"):
		emit_signal("pressed")
		await tween_color_to(Color.DARK_SLATE_GRAY)
		if focused:
			tween_color_to(Color.AQUA)
		else:
			tween_color_to(Color.WHITE)
