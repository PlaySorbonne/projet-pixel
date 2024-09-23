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
const STAND_NAMES : Array[String] = [
	"COLLECTION",
	"DOJO",
	"VAULT",
	"SHOP",
	"STATS"
]

@onready var vendor := $CanvasLayer/TextureVendor
@onready var stand_name := $CanvasLayer/Label
var can_input := false
var buttons : Array[Button] = [null]
var selected_button := 0
var current_stand := Screens.Default

func _ready():
	await get_tree().create_timer(0.5).timeout
	can_input = true

func _process(delta : float):
	if not can_input:
		return
	var b : Button = buttons[selected_button]
	if Input.is_action_just_pressed("down") or Input.is_action_just_pressed("right"):
		$AudioArrowDown.play(0.0)
		var new_button := selected_button + 1
		if new_button >= len(buttons):
			new_button = 0
		select_button(new_button)
	elif Input.is_action_just_pressed("up") or Input.is_action_just_pressed("left"):
		$AudioArrowUp.play(0.0)
		var new_button := selected_button - 1
		if new_button < 0:
			new_button = len(buttons) - 1
		select_button(new_button)
	elif Input.is_action_just_pressed("attack") or Input.is_action_just_pressed(
		"special") or Input.is_action_just_pressed("jump"):
		confirm_button()
		#b.emit_signal("pressed")

func select_button(button : int):
	pass

func confirm_button():
	current_stand += 1
	if current_stand > int(Screens.Stats):
		current_stand = 0
	go_to_screen(current_stand)

func _on_exit_progress_bar_bar_filled():
	get_tree().change_scene_to_file(MAIN_MENU)

func set_current_screen(new_screen : Screens):
	pass

func set_screen_infos(index : int, animated_infos := false):
	vendor.texture = VENDOR_TEXTURES[index]
	vendor.size = VENDOR_SIZES[index]
	stand_name.text = STAND_NAMES[index]
	if animated_infos:
		vendor.position = VENDOR_POSITIONS[index]

func go_to_screen(new_screen : Screens):
	const TRANS_TIME := 1.5
	const N_TRANS_TIME := 1.0
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SPRING)
	var index : int = int(new_screen)
	tween.tween_property(vendor, "position", Vector2(
		2200.0, vendor.position.y), TRANS_TIME)
	tween.tween_property(stand_name, "position", Vector2(516, 1300), N_TRANS_TIME)
	await tween.finished
	set_screen_infos(index)
	vendor.position = Vector2(
		2200.0,
		VENDOR_POSITIONS[index].y
	)
	tween = create_tween().set_parallel().set_trans(Tween.TRANS_SPRING)
	tween.tween_property(vendor, "position", VENDOR_POSITIONS[index], TRANS_TIME)
	tween.tween_property(stand_name, "position", Vector2(516, 897), N_TRANS_TIME)
