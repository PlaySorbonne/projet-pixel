extends Level

var total_damage : int = 0
var player_device := -1
var player_device_type := -1

func _ready():
	GameInfos.use_special_gameplay_data = true
	GlobalVariables.skip_fight_intro = true

func _on_button_back_pressed():
	get_tree().change_scene_to_file("res://scenes/Menus/MenuPersistent.tscn")

func _process(_delta):
	$LabelHits.global_position = $AnimeBox.global_position - Vector2(125.0, 200.0)

func _on_anime_box_hentai_hit(hit_damage : int):
	total_damage += hit_damage
	$LabelHits.text = "hit : " + str(hit_damage) + "\ntotal damage : " + str(total_damage)

func _input(event : InputEvent):
	var device_type : int
	if event is InputEventKey:
		device_type = 0
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		device_type = 1
	for p : PlayerCharacter in GameInfos.players:
		if event.device != player_device:
			player_device = event.device
			p.set_control_device(player_device)
		if device_type != player_device_type:
			player_device_type = device_type
			p.set_control_type(player_device_type)
	
