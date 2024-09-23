extends Node2D

enum Screens {Collection, Dojo, Default, Shop, Stats}

const MAIN_MENU := "res://scenes/Menus/MenuPersistent.tscn"
const VENDOR_TEXTURES : Array[Texture] = [
	preload("res://resources/images/characters/CEO/IMG_5862.png"),
	preload("res://resources/images/characters/fox/fox_idle.png"),
	preload("res://resources/images/characters/Sheep/moutondroit.png"),
	preload("res://resources/images/characters/chicken/poulet_copie.png"),
	preload("res://resources/images/characters/template/robot_hit.png")
]
const VENDOR_SIZES : Array[Vector2] = [
	Vector2(749, 675),
	Vector2(553, 498),
	Vector2(473, 426),
	Vector2(571, 514),
	Vector2(473, 426)
]
const VENDOR_POSITIONS : Array[Vector2] = [
	Vector2(860, 296),
	Vector2(1056, 473),
	Vector2(1091, 528),
	Vector2(974, 489),
	Vector2(1091, 528)
]

@onready var vendor := $CanvasLayer/TextureVendor

func _on_exit_progress_bar_bar_filled():
	get_tree().change_scene_to_file(MAIN_MENU)

func set_current_screen(new_screen : Screens):
	pass

func go_to_screen(new_screen : Screens):
	var tween := create_tween()
	var index : int = int(new_screen)
	var new_pos := Vector2(
		2200.0,
		vendor.position.y
	)
	tween.tween_property(vendor, "position", new_pos, 0.75)
	tween.tween_property(vendor, "position", VENDOR_POSITIONS[index], 0.75)
	await tween.step_finished
	vendor.texture = VENDOR_TEXTURES[index]
	vendor.size = VENDOR_SIZES[index]
