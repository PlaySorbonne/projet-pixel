extends ScrollContainer
class_name XYZ_ScrollFocusedChildren

@export var parent_container : Container

func _ready():
	for c : Control in parent_container.get_children():
		c.connect("focus_entered", ensure_focus.bind(c))

func ensure_focus(c : Control):
	"""var new_scroll_down := int(c.position.y + c.size.y - size.y - scroll_vertical)
	if new_scroll_down > scroll_vertical:
		scroll_vertical = new_scroll_down
	else:
		scroll_vertical = int()"""
	scroll_vertical = int(c.position.y + c.size.y - size.y + scroll_vertical)
