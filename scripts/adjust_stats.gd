extends CanvasLayer

const EvolutionSpecials = {
	"CEO" : preload("res://scenes/Menus/Submenus/AbilityEditor/ceo_ability.tscn"),
	"Manager" : preload("res://scenes/Menus/Submenus/AbilityEditor/director_ability.tscn"),
	"Employee" : preload("res://scenes/Menus/Submenus/AbilityEditor/employee_ability.tscn"),
	"Mascot" : preload("res://scenes/Menus/Submenus/AbilityEditor/mascot_ability.tscn"),
	"Weeb" : preload("res://scenes/Menus/Submenus/AbilityEditor/weeb_ability.tscn"),
	"Ascended" : preload("res://scenes/Menus/Submenus/AbilityEditor/weeb_ability.tscn")
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
	if not GameInfos.game_started:
		queue_free()
	for c in $Adjuster/VBoxContainer.get_children():
		if c.has_method("_on_description_changed"):
			variable_adjusters.append(c)
	var data_keys : Array[String] = PlayerCharacter.Evolutions.keys().duplicate()
	data_keys.append("Ascended")
	variables_data = SettingsScreen.gameplay_data.duplicate()
	
	for ev : String in data_keys:
		# get character data
		char_selector.add_item(ev)
		var curr_ev
		if ev == "Ascended":
			curr_ev = PlayerCharacter.Evolutions.Weeb
		else:
			curr_ev = PlayerCharacter.Evolutions[ev]
		var p : PlayerCharacter = PlayerCharacter.EvolutionCharacters[curr_ev].instantiate()
		for adj : VariableAdjuster in variable_adjusters:
			if ev == "CEO" and variables_data[ev].has(adj.variable_name):
				adj.variable_default_value = variables_data[ev][adj.variable_name]
		
		# get ability data
		var spe : SpecialAbilityEditor = EvolutionSpecials[ev].instantiate()
		if ev == "CEO":
			var spe_current : SpecialAbilityEditor = CurrentSpecialBox
			for adj_r : VariableAdjuster in spe_current.get_variables():
				if variables_data[ev+"_special"].has(adj_r.variable_name):
					adj_r.variable_default_value = variables_data[ev+"_special"][adj_r.variable_name]
		
		spe.queue_free()
		p.queue_free()
	char_selector.select(0)
	set_adjuster_active(false)
	for c in variable_adjusters:
		c.connect("var_changed", actualize_characters)
	connect_special_box()

func connect_special_box():
	for c in CurrentSpecialBox.get_variables():
		c.connect("var_changed", actualize_specials)

func actualize_characters(do_update_data := true):
	if do_update_data:
		update_data()
	for player : PlayerCharacter in GameInfos.players.values():
		var ev = PlayerCharacter.Evolutions.find_key(player.current_evolution)
		for k : String in variables_data[ev].keys():
			player.set(k, variables_data[ev][k])

func actualize_specials(do_update_data := true):
	for player : PlayerCharacter in GameInfos.players.values():
		var ev : String = PlayerCharacter.Evolutions.find_key(player.current_evolution)
		if player.ascended:
			ev = "Ascended"
		var ev_spe := ev+"_special"
		for k : String in variables_data[ev_spe].keys():
			player.get_special_attack().set(k, variables_data[ev_spe][k])

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
		if variables_data.has(k) and variables_data[k].has(adj.variable_name):
			adj.value = variables_data[k][adj.variable_name]
	dont_update_data = false
	rebuild_special_ability_box(k)

func rebuild_special_ability_box(current_character : String):
	CurrentSpecialBox.queue_free()
	CurrentSpecialBox = EvolutionSpecials[current_character].instantiate()
	special_vbox.add_child(CurrentSpecialBox)
	var k := current_character+"_special"
	for adj_r : VariableAdjuster in CurrentSpecialBox.get_variables():
		if variables_data.has(k) and variables_data[k].has(adj_r.variable_name):
			adj_r.variable_default_value = variables_data[k][adj_r.variable_name]
	connect_special_box()

func update_data():
	if dont_update_data:
		return
	var index : int = $Adjuster/VBoxContainer/OptionButton.selected
	var k : String = $Adjuster/VBoxContainer/OptionButton.get_item_text(index)
	for adj : VariableAdjuster in variable_adjusters:
		variables_data[k][adj.variable_name] = adj.value
	update_special_ability_data(k)

func update_special_ability_data(current_evolution : String):
	var k := current_evolution + "_special"
	for adj : VariableAdjuster in CurrentSpecialBox.get_variables():
		variables_data[k][adj.variable_name] = adj.value

func _on_button_save_pressed():
	$FileDialog.file_mode = 4
	is_saving_data = true
	$FileDialog.popup_centered()

func _on_button_load_pressed():
	$FileDialog.file_mode = 0
	is_saving_data = false
	$FileDialog.popup_centered()

func _on_file_dialog_file_selected(path):
	if is_saving_data:
		save_custom_data(path)
	else:
		load_custom_data(path)

func load_custom_data(path):
	var save_game = FileAccess.open(path, FileAccess.READ)
	variables_data = SettingsScreen.update_stats_data(save_game)
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
	actualize_specials(false)

func _on_button_refresh_pressed():
	actualize_characters(true)
	actualize_specials(true)
	$Adjuster/VBoxContainer/HBoxContainer/ButtonRefresh.release_focus()
