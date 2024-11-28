extends Control
class_name TitleItem

enum Rarities {Common, Rare, Legendary}

var item_rarity := Rarities.Common

var player_stats_parent : PlayerVictoryStats

func _ready() -> void:
	$Label.modulate = Color.TRANSPARENT

func set_title(title : String, rarity : Rarities) -> void:
	const RARE_COLORS := ["purple", "red", "cadet_blue", "violet", "teal", "slate_blue",
			"peru", "blue", "green", "dark_green"]
	const COMMON_COLORS := ["gray", "dark_gray", "slate_gray", "light_gray", "light_blue", 
			"salmon", "cyan", "aquamarine", "blanched_almond", "burlywood"]
	var effects_intro : String = "[center]"
	item_rarity = rarity
	# add text effects depending on rarity and chance
	match item_rarity:
		Rarities.Common:
			if randi()%3 == 0:
				if randi()%2 == 0:
					var pulse_color : String = COMMON_COLORS.pick_random() + " ease=-2.0]"
					effects_intro = effects_intro + "[pulse freq=1.0 color="+pulse_color
				else:
					var text_color : String = COMMON_COLORS.pick_random() + "]"
					effects_intro = effects_intro + "[color=" + text_color
		Rarities.Rare:
			if randi()%2 == 0:
				var pulse_color : String = RARE_COLORS.pick_random() + "ff ease=-2.0]"
				effects_intro = effects_intro + "[pulse freq=1.3 color="+pulse_color
			else:
				var text_color : String = RARE_COLORS.pick_random() + "ff]"
				effects_intro = effects_intro + "[color=" + text_color
			if randi()%2 == 0 or true:
				effects_intro = effects_intro + "[shake rate=20.0 level=5 connected=1]"
			else:
				effects_intro = effects_intro + "[tornado radius=2.5 freq=5.0 connected=1]"
		Rarities.Legendary:
			effects_intro = effects_intro + "[tornado radius=3.5 freq=8.0 connected=1]"
			effects_intro = effects_intro + "[rainbow freq=0.8 sat=0.5 val=0.9]"
	$Label.text = effects_intro + title

func anim_intro() -> void:
	match item_rarity:
		Rarities.Common:
			$AnimationPlayer.play("intro_common")
		Rarities.Rare:
			$AnimationPlayer.play("intro_rare")
			await $AnimationPlayer.animation_finished
			player_stats_parent.shake_node(false)
		Rarities.Legendary:
			$AnimationPlayer.play("intro_legendary")
			await $AnimationPlayer.animation_finished
			player_stats_parent.shake_node(true)
