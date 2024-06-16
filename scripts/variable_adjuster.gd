@tool
extends HBoxContainer
class_name VariableAdjuster

@export var variable_name := "HaelthPionts" : set=_on_var_name_changed
@export var variable_description := "descritpion" : set=_on_description_changed
@export var is_integer := false

var value = -1 : set=_on_value_changed
var target_object : PlayerCharacter.Evolutions = PlayerCharacter.Evolutions.CEO
var variable_default_value = -1 : set=_on_default_value_changed

func _ready():
	if is_integer:
		$SpinBox.rounded = true
		$LabelName.text = variable_name
		$SpinBox.step = 1

func _on_default_value_changed(new_val):
	$SpinBox.value = new_val
	variable_default_value = new_val

func _on_value_changed(new_val):
	$SpinBox.value = new_val
	value = new_val

func _on_description_changed(new_val : String):
	variable_description = new_val
	$Description.text = variable_description

func _on_var_name_changed(new_val : String):
	variable_name = new_val
	$LabelName.text = variable_name

func _on_button_reset_pressed():
	$SpinBox.value = variable_default_value

func _on_spin_box_value_changed(new_val : float):
	if is_integer:
		value = int(new_val)
	else:
		value = new_val

