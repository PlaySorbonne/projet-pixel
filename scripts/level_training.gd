extends Level

var total_damage : int = 0

func _on_button_back_pressed():
	get_tree().change_scene_to_file("res://scenes/Menus/MenuPersistent.tscn")

func _process(_delta):
	$LabelHits.global_position = $AnimeBox.global_position - Vector2(125.0, 200.0)

func _on_anime_box_hentai_hit(hit_damage : int):
	total_damage += hit_damage
	$LabelHits.text = "hit : " + str(hit_damage) + "\ntotal damage : " + str(total_damage)
