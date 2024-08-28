extends CanvasLayer

const EvolutionSpecials = {
	"CEO" : preload("res://scenes/Menus/Submenus/AbilityEditor/ceo_ability.tscn"),
	"Manager" : preload("res://scenes/Menus/Submenus/AbilityEditor/director_ability.tscn"),
	"Employee" : preload("res://scenes/Menus/Submenus/AbilityEditor/employee_ability.tscn"),
	"Mascot" : preload("res://scenes/Menus/Submenus/AbilityEditor/mascot_ability.tscn"),
	"Weeb" : preload("res://scenes/Menus/Submenus/AbilityEditor/weeb_ability.tscn")
}

var last_open_file_path : String = ""
var is_active := false
@onready var char_selector := $Adjuster/VBoxContainer/OptionButton
@onready var saved_path_node := $Adjuster/VBoxContainer/HBoxContainer/LabelLastPath
@onready var special_vbox := $Adjuster/SpecialsEditor/VBoxContainer
@onready var CurrentSpecialBox : SpecialAbilityEditor = $Adjuster/SpecialsEditor/VBoxContainer/CEOability
var variable_adjusters : Array = []
var variables_data : Dictionary = {}
var is_saving_data := true
var dont_update_data := false

func _ready():
	for c in $Adjuster/VBoxContainer.get_children():
		if c.has_method("_on_description_changed"):
			variable_adjusters.append(c)
	var data_keys : Array = PlayerCharacter.Evolutions.keys()
	for ev : String in data_keys:
		# get character data
		var evolution_data : Dictionary = {}
		char_selector.add_item(ev)
		var curr_ev = PlayerCharacter.Evolutions[ev]
		var p : PlayerCharacter = PlayerCharacter.EvolutionCharacters[curr_ev].instantiate()
		for adj : VariableAdjuster in variable_adjusters:
			evolution_data[adj.variable_name] = p.get(adj.variable_name)
			if ev == "CEO":
				adj.variable_default_value = evolution_data[adj.variable_name]
		
		# get ability data
		var special_ability_data : Dictionary = {}
		var spe : SpecialAbilityEditor = EvolutionSpecials[ev].instantiate()
		for adj : VariableAdjuster in spe.get_variables():
			special_ability_data[adj.variable_name] = p.get_special_attack().get(adj.variable_name)
		if ev == "CEO":
			var spe_current : SpecialAbilityEditor = CurrentSpecialBox
			for adj_r : VariableAdjuster in spe_current.get_variables():
				adj_r.variable_default_value = special_ability_data[adj_r.variable_name]
		
		spe.queue_free()
		p.queue_free()
		
		# add data to dict
		variables_data[ev] = evolution_data
		variables_data[ev+"_special"] = special_ability_data
	char_selector.select(0)
	set_adjuster_active(false)
	for c in variable_adjusters:
		c.connect("var_changed", actualize_characters)

func actualize_characters(do_update_data := true):
	if do_update_data:
		update_data()
	#print(GameInfos.players)
	for player : PlayerCharacter in GameInfos.players:
		var ev = PlayerCharacter.Evolutions.find_key(player.current_evolution)
		for k : String in variables_data[ev].keys():
			player.set(k, variables_data[ev][k])

func _on_button_pressed():
	set_adjuster_active(not is_active)

func set_adjuster_active(new_active : bool):
	is_active = new_active
	$Adjuster.visible = is_active

func _on_option_button_item_selected(_index):
	update_infos()

func update_infos():
	dont_update_data = true
	var index = $Adjuster/VBoxContainer/OptionButton.selected
	var k : String = $Adjuster/VBoxContainer/OptionButton.get_item_text(index)
	for adj : VariableAdjuster in variable_adjusters:
		adj.value = variables_data[k][adj.variable_name]
	dont_update_data = false
	rebuild_special_ability_box(k)

func rebuild_special_ability_box(current_character : String):
	CurrentSpecialBox.queue_free()
	CurrentSpecialBox = EvolutionSpecials[current_character].instantiate()
	special_vbox.add_child(CurrentSpecialBox)
	print("TODO")

func update_data():
	if dont_update_data:
		return
	var index = $Adjuster/VBoxContainer/OptionButton.selected
	var k = $Adjuster/VBoxContainer/OptionButton.get_item_text(index)
	for adj : VariableAdjuster in variable_adjusters:
		variables_data[k][adj.variable_name] = adj.value
	update_special_ability_data()

func update_special_ability_data():
	print("TODO")

func _on_button_save_pressed():
	$FileDialog.file_mode = 4
	$FileDialog.popup_centered()
	is_saving_data = true

func _on_button_load_pressed():
	$FileDialog.file_mode = 0
	$FileDialog.popup_centered()
	is_saving_data = false

func _on_file_dialog_file_selected(path):
	if is_saving_data:
		save_custom_data(path)
	else:
		load_custom_data(path)

func load_custom_data(path):
	var save_game = FileAccess.open(path, FileAccess.READ)
	var ordered_keys := {}
	var number_of_evolutions := len(PlayerCharacter.Evolutions)
	for i in PlayerCharacter.Evolutions.values():
		var key : String = PlayerCharacter.Evolutions.find_key(i)
		ordered_keys[i] = key
		ordered_keys[i + number_of_evolutions] = key + "_special"
	var line = 0
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			line += 1
			continue
		var ev_data = json.get_data()
		variables_data[ordered_keys[line]] = ev_data
		line += 1
	update_infos()

func save_custom_data(path):
	update_data()
	var save_game = FileAccess.open(path, FileAccess.WRITE)
	for i in PlayerCharacter.Evolutions.values():
		var k : String = PlayerCharacter.Evolutions.find_key(i)
		save_game.store_line(JSON.stringify(variables_data[k]))
	for i in PlayerCharacter.Evolutions.values():
		var k : String = PlayerCharacter.Evolutions.find_key(i) + "_special"
		save_game.store_line(JSON.stringify(variables_data[k]))
		

func _on_option_button_button_down():
	update_data()

func _on_timer_timeout():
	actualize_characters(false)
