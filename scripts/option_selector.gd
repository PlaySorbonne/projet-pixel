@tool
extends HBoxContainer
class_name OptionSelector

signal option_changed

@export var minimum_label_width := 100.0:
	set(value):
		minimum_label_width = value
		$Label.custom_minimum_size.x = minimum_label_width
@export var options : Array[String] = []
@export var selected_option : int = 0:
	set(value):
		if options.size() == 0:
			selected_option = 0
			return
		if value >= options.size():
			selected_option = 0
		elif value < 0:
			selected_option = options.size() - 1
		else:
			selected_option = value
		$Label.text = options[selected_option]
		emit_signal("option_changed", selected_option)

func _ready():
	if options.size() > 0:
		$Label.text = options[selected_option]

func get_text() -> String:
	return $Label.text

func _on_previous_button_pressed():
	selected_option -= 1

func _on_next_button_pressed():
	selected_option += 1
