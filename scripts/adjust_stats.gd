extends CanvasLayer

var is_active := false
@onready var char_selector := $Adjuster/VBoxContainer/OptionButton

func _ready():
	for ev in PlayerCharacter.Evolutions.keys():
		char_selector.add_item(ev)
	char_selector.select(0)
	set_adjuster_active(false)

func _on_button_pressed():
	set_adjuster_active(not is_active)

func set_adjuster_active(new_active : bool):
	is_active = new_active
	$Adjuster.visible = is_active
