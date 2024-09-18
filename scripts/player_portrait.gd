extends Control
class_name PlayerPortrait

const PLAYER_PORTRAITS = [
	preload("res://resources/images/champgrumpf.png"),
	preload("res://resources/images/characters/fox/fox_portrait.png"),
	preload("res://resources/images/characters/Sheep/mouton_portrait.png"),
	preload("res://resources/images/characters/chicken/chicken_portrait.png"),
	preload("res://sprites/champsu_only.svg")
]

var player_number := 0
var current_evolution := -1
var init_portrait := false

func initialize_portrait(player_num : int):
	player_number = player_num
	$Holder/TextureBackground.modulate = GameInfos.players_data[player_num]["color"]
	connect_player_object()
	update_health()
	update_evolution()
	var player : PlayerCharacter = GameInfos.players[player_num]
	$Holder/LabelName.text = GameInfos.players_data[player_num]["name"]

func connect_player_object():
	var player = GameInfos.players[player_number]
	player.fighter_hit.connect(update_health)
	player.player_spawned.connect(update_health)
	player.player_evolved.connect(update_evolution)

func update_health(_damage := 0, _hitpoints := 0):
	var player : PlayerCharacter = GameInfos.players[player_number]
	$Holder/LabelHealth.text = str(max(0, player.hitpoints)
	) + "/" + str(player.max_hitpoints)

func update_evolution(_evolution = null):
	connect_player_object()
	var new_evolution = GameInfos.players[player_number].current_evolution
	if new_evolution == current_evolution:
		return
	if init_portrait:
		
		$Shaker.shake(0.35, 25, 20)
		$AnimationPlayer.play("evolve")
		tween_labels_color()
	else:
		init_portrait = true
	current_evolution = new_evolution
	var new_texture = PLAYER_PORTRAITS[new_evolution]
	var new_name : String = PlayerCharacter.Evolutions.keys()[new_evolution]
	$Holder/TexturePortrait.texture = new_texture
	$Holder/TexturePortraitBackground.texture = new_texture
	$Holder/LabelEvolution.text = new_name
	update_health()

func tween_labels_color():
	var labels : Array[Control] = [$Holder/LabelName, $Holder/LabelHealth, $Holder/LabelEvolution]
	var new_color : Color = Color.GOLD
	var anim_time := 0.25
	for i in range(2):
		var t : Tween = get_tree().create_tween()
		t.tween_property(labels[0], "modulate", new_color, anim_time)
		t.parallel().tween_property(labels[1], "modulate", new_color, anim_time)
		t.parallel().tween_property(labels[2], "modulate", new_color, anim_time)
		await get_tree().create_timer(0.1+anim_time).timeout
		new_color = Color.WHITE
		anim_time = 0.5
