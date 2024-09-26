extends HBoxContainer
class_name XYZ_ClickableHBox

signal pressed

const COLOR_DEFAULT := Color.WHITE
const COLOR_PRESSED := Color.DARK_SLATE_GRAY
const COLOR_FOCUSED := Color.ORANGE

@onready var focused : bool = has_focus()

func _ready():
	self.connect("focus_entered", add_focus)
	self.connect("focus_exited", remove_focus)

func add_focus():
	focused = true
	tween_color_to(COLOR_FOCUSED)

func tween_color_to(color : Color, force := false) -> Tween:
	var tween := create_tween()
	tween.tween_property(self, "modulate", color, 0.1)
	return tween

func remove_focus():
	focused = false
	tween_color_to(COLOR_DEFAULT)

func _process(_delta : float):
	if focused and Input.is_action_just_pressed("ui_accept"):
		emit_signal("pressed")
		await tween_color_to(COLOR_PRESSED).finished
		if focused:
			tween_color_to(COLOR_FOCUSED)
		else:
			tween_color_to(COLOR_DEFAULT)
