extends Control
class_name TitleItem

enum Rarities {Common, Rare, Legendary}

var item_rarity := Rarities.Common

func set_title(title : String, rarity : Rarities) -> void:
	var effect_intro : String = ""
	var effect_outro : String = ""
	item_rarity = rarity
	match item_rarity:
		Rarities.Common:
			pass
		Rarities.Rare:
			pass
		Rarities.Legendary:
			pass
	$Label.text = effect_intro + title + effect_outro

func anim_intro() -> void:
	match item_rarity:
		Rarities.Common:
			pass
		Rarities.Rare:
			pass
		Rarities.Legendary:
			pass
