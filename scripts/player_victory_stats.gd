extends Control
class_name PlayerVictoryStats

const TITLE_ITEM := preload("res://scenes/Menus/title_item.tscn")

func shake_node() -> void:
	$Shaker.shake(0.25, 15, 40)

func set_player_evolution(current_ev : int) -> void:
	$Main/LabelEvolution.text = str(PlayerCharacter.Evolutions.keys()[current_ev])
	$Main/TexturePortrait.texture = PlayerPortrait.PLAYER_PORTRAITS[current_ev]

func set_player_titles(common_titles : Array[String], rare_titles : Array[String], 
			legendary_titles : Array[String]) -> void:
	# load data in custom dictionary
	var all_titles : Dictionary = {}
	for title : String in common_titles:
		all_titles[title] = 0
	for title : String in rare_titles:
		all_titles[title] = 1
	for title : String in legendary_titles:
		all_titles[title] = 2
	# create title nodes and initialize them
	for title : String in all_titles.keys():
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
		await get_tree().create_timer(0.2).timeout
		t_item.anim_intro()
