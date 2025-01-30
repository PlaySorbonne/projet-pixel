extends Control
class_name PlayerVictoryStats

const TITLE_ITEM := preload("res://scenes/Menus/title_item.tscn")

var player_stats : PlayerStats = null
var player_title_objects : Array[TitleItem] = []
var is_winner := false

@onready var stats_labels := [
	$Main/LabelDeaths,
	$Main/LabelKills,
	$Main/LabelDamageTaken,
	$Main/LabelDamageGiven,
	$Main/LabelTime
]
@onready var subnodes := [
	$Main/LabelOutcome,
	$Main/LabelName,
	$Main/LabelEvolution,
	$Main/LabelTitles
]

func _ready() -> void:
	$Main.position.x = -6000.0
	$Main/TexturePortrait.scale = Vector2.ZERO
	for l : Label in stats_labels + subnodes:
		l.modulate = Color.TRANSPARENT

func set_player_stats(p_stats : PlayerStats) -> void:
	player_stats = p_stats
	$Main/LabelName.text = p_stats.player_name
	var pc : PlayerCharacter = GameInfos.players[p_stats.player_id]
	$Main/TexturePortrait/TexturePortraitBG.self_modulate = pc.player_color
	var current_ev := int(pc.current_evolution)
	if pc.current_evolution == PlayerCharacter.Evolutions.Weeb and pc.ascended:
		$Main/LabelEvolution.text = "ASCENDED_WEEB"
		WeebCharacter.apply_exalted_material($Main/TexturePortrait, 100.0)
		#$Main/TexturePortrait.material = CHROMATIC_ABERRATION_MAT
		#$Main/TexturePortrait.material.set_shader_parameter("chaos", 100)
		#$Main/TexturePortrait.material.set_shader_parameter("divider_green", 2.0)
		#$Main/TexturePortrait.material.set_shader_parameter("divider_blue",  1.25)
	else:
		$Main/LabelEvolution.text = str(PlayerCharacter.Evolutions.keys()[current_ev])
	$Main/TexturePortrait.texture = PlayerPortrait.PLAYER_PORTRAITS[current_ev]

func declare_winner() -> void:
	is_winner = true
	$Main/LabelOutcome.text = "WINNER"
	$Main/LabelOutcome/LastWinner.declare_winner()

func intro_animation() -> void:
	$Main/AnimationPlayer.play("intro")
	await $Main/AnimationPlayer.animation_finished
	$Main/AnimationPlayer.play("intro_subnodes")
	await $Main/AnimationPlayer.animation_finished
	$Main/AnimationPlayer.play("idle")
	# initialize stats
	set_label_int_value($Main/LabelDeaths/Label, player_stats.deaths)
	await get_tree().create_timer(0.25).timeout
	set_label_int_value($Main/LabelKills/Label, player_stats.kills)
	await get_tree().create_timer(0.25).timeout
	set_label_int_value($Main/LabelDamageTaken/Label, player_stats.damage_received)
	await get_tree().create_timer(0.25).timeout
	set_label_int_value($Main/LabelDamageGiven/Label, player_stats.damage_given)
	await get_tree().create_timer(0.25).timeout
	var time_ascended := 0.0
	var p : PlayerCharacter = GameInfos.players[player_stats.player_id]
	if p.has_method("get_time_ascended"):
		time_ascended = p.get_time_ascended()
	set_label_int_value($Main/LabelTime/Label, int(time_ascended), time_ascended)
	for l : Label in stats_labels:
		intro_tween_label(l)
		await get_tree().create_timer(0.25).timeout
	# initialize titles
	await get_tree().create_timer(0.4).timeout
	for t_item : TitleItem in player_title_objects:
		$TimerTitles.start(0.15)
		await $TimerTitles.timeout
		t_item.anim_intro()

func intro_tween_label(l : Label) -> void:
	var t := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC)
	l.modulate = Color.TRANSPARENT
	l.scale = Vector2(2.0, 2.0)
	t.tween_property(l, "modulate", Color.WHITE, 0.3)
	t.tween_property(l, "scale", Vector2.ONE, 0.3)
	await t.finished

func set_label_int_value(label : Label, value : int, float_val := -1.0) -> void:
	for _i : int in range(30):
		label.text = str(randi_range(0, 999)).pad_zeros(3)
		await get_tree().create_timer(0.075).timeout
	if float_val >= 0.0:
		label.text = str(value).pad_zeros(3) + "." + str(
								int((float_val-value)*10)).pad_zeros(1)
	else:
		label.text = str(value).pad_zeros(3)

func shake_node(strong_shake := true) -> void:
	if strong_shake:
		$Shaker.shake(0.2, 15, 45)
	else:
		$Shaker.shake(0.1, 15, 25)

func set_player_titles(common_titles : Array, rare_titles : Array, 
			legendary_titles : Array) -> void:
	# load data in custom dictionary
	var all_titles : Dictionary = {}
	for title : String in common_titles:
		all_titles[title] = 0
	for title : String in rare_titles:
		all_titles[title] = 1
	for title : String in legendary_titles:
		all_titles[title] = 2
	# create title nodes and initialize them
	var all_titles_array : Array = all_titles.keys()
	all_titles_array.shuffle()
	for title : String in all_titles_array:
		if not VaultData.vault_data.has("unlocked_titles"):
			VaultData.vault_data["unlocked_titles"] = []
		VaultData.vault_data["unlocked_titles"].append(title)
		var t_item := TITLE_ITEM.instantiate()
		t_item.player_stats_parent = self
		match all_titles[title]:
			0:
				t_item.set_title(title, TitleItem.Rarities.Common)
			1:
				t_item.set_title(title, TitleItem.Rarities.Rare)
			2:
				t_item.set_title(title, TitleItem.Rarities.Legendary)
		$Main/LabelTitles/TitlesContainer.add_child(t_item)
		player_title_objects.append(t_item)
