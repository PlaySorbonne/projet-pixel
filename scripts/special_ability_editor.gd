extends VBoxContainer
class_name SpecialAbilityEditor


func get_variables():
	var childrenVariableAdjusters : Array = []
	for c : Control in get_children():
		if c != $Label:
			childrenVariableAdjusters.append(c)
	return childrenVariableAdjusters
