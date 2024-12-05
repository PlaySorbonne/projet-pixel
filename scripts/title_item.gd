extends Control
class_name TitleItem

enum Rarities {Common, Rare, Legendary}

const BIG_EXPLOSION_SFX := preload("res://resources/audio/sfx/ui_sfx/explosion.wav")
const MID_EXPLOSION_SFX := preload("res://resources/audio/sfx/ui_sfx/explosion_mid.wav")
const MONEY_AMOUNT := {
	Rarities.Common: 100,
	Rarities.Rare : 400,
	Rarities.Legendary : 1500
}

var item_rarity := Rarities.Common

var player_stats_parent : PlayerVictoryStats

func _ready() -> void:
	$Label.modulate = Color.TRANSPARENT

func set_title(title : String, rarity : Rarities) -> void:
	const RARE_COLORS := ["red", "cadet_blue", "violet", "teal", "hot_pink", "khaki",
			"peru", "sky_blue", "green", "lime_green", "orange", "salmon"]
	const COMMON_COLORS := ["gray", "gray", "slate_gray", "light_gray", "light_yellow",
			"blanched_almond", "burlywood", "white", "white"]
	var effects_intro : String = "[center]"
	item_rarity = rarity
	# add text effects depending on rarity and chance
	$AudioBoom.pitch_scale = randf_range(0.9, 1.1)
	match item_rarity:
		Rarities.Common:
			var text_color : String = COMMON_COLORS.pick_random() + "]"
			effects_intro = effects_intro + "[color=" + text_color
		Rarities.Rare:
			$AudioBoom.stream = MID_EXPLOSION_SFX
			if randi() % 2 == 0:
				var pulse_color : String = RARE_COLORS.pick_random() + " ease=-2.0]"
				effects_intro = effects_intro + "[pulse freq=1.3 color="+pulse_color
			else:
				var text_color : String = RARE_COLORS.pick_random()
				effects_intro = effects_intro + "[color=" + text_color + "]"
			effects_intro = effects_intro + "[shake rate=20.0 level=5 connected=1]"
		Rarities.Legendary:
			$AudioBoom.stream = BIG_EXPLOSION_SFX
			effects_intro = effects_intro + "[tornado radius=3.5 freq=8.0 connected=1]"
			effects_intro = effects_intro + "[rainbow freq=0.8 sat=0.5 val=0.9]"
	$Label.text = effects_intro + title

func anim_intro() -> void:
	match item_rarity:
		Rarities.Common:
			$AnimationPlayer.play("intro_common")
			await $AnimationPlayer.animation_finished
			GameInfos.end_screen.add_money(MONEY_AMOUNT[Rarities.Common])
		Rarities.Rare:
			$AnimationPlayer.play("intro_rare")
			await $AnimationPlayer.animation_finished
			GameInfos.end_screen.add_money(MONEY_AMOUNT[Rarities.Rare])
			player_stats_parent.shake_node(false)
		Rarities.Legendary:
			$AnimationPlayer.play("intro_legendary")
			await $AnimationPlayer.animation_finished
			GameInfos.end_screen.add_money(MONEY_AMOUNT[Rarities.Legendary])
			player_stats_parent.shake_node(true)
	$AudioBoom.play()
