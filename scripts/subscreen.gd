extends Control
class_name SubScreen


signal screen_focused
signal ButtonBackPressed


func _ready() -> void:
	var back : XYZ_Button = get_node("ButtonBack")
	connect("screen_focused", back.set_gamepad_clickable)
