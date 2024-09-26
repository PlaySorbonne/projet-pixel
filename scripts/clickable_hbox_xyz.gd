extends HBoxContainer
class_name XYZ_ClickableHBox

signal pressed

@onready var focused : bool = has_focus()

func _ready():
	self.connect("focus_entered", add_focus)
	self.connect("focus_exited", remove_focus)

func add_focus():
	focused = true

func remove_focus():
	focused = false

func _process(_delta : float):
	if focused and Input.is_action_just_pressed("ui_accept"):
		emit_signal("pressed")
