extends CanvasLayer

var last_open_file_path : String = ""
var is_active := false
@onready var char_selector := $Adjuster/VBoxContainer/OptionButton
@onready var saved_path_node := $Adjuster/VBoxContainer/HBoxContainer/LabelLastPath
var variable_adjusters : Array = []
var variables_data : Dictionary = {}
var is_saving_data := true
var dont_update_data := false

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
	for c in variable_adjusters:
		c.connect("var_changed", actualize_characters)

func actualize_characters(do_update_data := true):
	if do_update_data:
		update_data()
	print(GameInfos.players)
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
	var k = $Adjuster/VBoxContainer/OptionButton.get_item_text(index)
	for adj : VariableAdjuster in variable_adjusters:
		adj.value = variables_data[k][adj.variable_name]
	dont_update_data = false

func update_data():
	if dont_update_data:
		return
	var index = $Adjuster/VBoxContainer/OptionButton.selected
	var k = $Adjuster/VBoxContainer/OptionButton.get_item_text(index)
	for adj : VariableAdjuster in variable_adjusters:
		variables_data[k][adj.variable_name] = adj.value

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
	for i in PlayerCharacter.Evolutions.values():
		ordered_keys[i] = PlayerCharacter.Evolutions.find_key(i)
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

func _on_option_button_button_down():
	update_data()

func _on_timer_timeout():
	actualize_characters(false)
