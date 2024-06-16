extends CanvasLayer

var is_active := false
var last_open_file_path : String = "user://ProjetPixelGDdata.txt"
@onready var char_selector := $Adjuster/VBoxContainer/OptionButton
@onready var saved_path_node := $Adjuster/VBoxContainer/HBoxContainer/LabelLastPath
var variable_adjusters : Array = []
var variables_data : Dictionary = {}

func _ready():
	for c in $Adjuster/VBoxContainer.get_children():
		if c.has_method("_on_description_changed"):
			variable_adjusters.append(c)
	for ev in PlayerCharacter.Evolutions.keys():
		char_selector.add_item(ev)
		var evolution_data = {}
		var curr_ev = PlayerCharacter.Evolutions[ev]
		var p : PlayerCharacter = PlayerCharacter.EvolutionCharacters[curr_ev].instantiate()
		for adj : VariableAdjuster in variable_adjusters:
			evolution_data[adj.variable_name] = p.get(adj.variable_name)
			if ev == "CEO":
				adj.variable_default_value = evolution_data[adj.variable_name]
		p.queue_free()
		variables_data[ev] = evolution_data
	char_selector.select(0)
	set_adjuster_active(false)

func _on_button_pressed():
	set_adjuster_active(not is_active)

func set_adjuster_active(new_active : bool):
	is_active = new_active
	$Adjuster.visible = is_active

func _on_button_save_pressed():
	var save_game = FileAccess.open(last_open_file_path, FileAccess.WRITE)
	save_game.store_line(JSON.stringify(variables_data))
	saved_path_node.text = "saved to: " + last_open_file_path

func _on_option_button_item_selected(index):
	$Adjuster/VBoxContainer/OptionButton.get_item_text(index)
