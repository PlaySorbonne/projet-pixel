extends ScrollContainer
class_name XYZ_ScrollFocusedChildren

@export var parent_container : Container

func _ready():
	ensure_children_focus()

func ensure_children_focus():
	for c : Control in parent_container.get_children():
		c.connect("focus_entered", ensure_focus.bind(c))

func ensure_focus(c : Control):
	scroll_vertical = int(c.position.y + c.size.y - size.y + scroll_vertical)
