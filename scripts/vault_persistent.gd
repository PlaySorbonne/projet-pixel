extends Node2D

enum Screens {Collection, Dojo, Default, Shop, Stats}
enum FocusType {Screens, ScreenOptions}

const MAIN_MENU := "res://scenes/Menus/MenuPersistent.tscn"
const SCREENS_ORDER := [
	Screens.Collection,
	Screens.Dojo,
	Screens.Default,
	Screens.Shop,
	Screens.Stats
]
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
@onready var screen_nodes : Array[VaultSubScreen] = [
	$CanvasLayer/Collection,
	$CanvasLayer/Dojo,
	$CanvasLayer/Vault,
	$CanvasLayer/Shop,
	$CanvasLayer/Stats
]
@onready var current_screen : VaultSubScreen = $CanvasLayer/Vault
@onready var navigation_icons : Array[Button] = [
	$CanvasLayer/TextureBooth/HBoxContainer/IconCollection,
	$CanvasLayer/TextureBooth/HBoxContainer/IconDojo,
	$CanvasLayer/TextureBooth/HBoxContainer/IconVault,
	$CanvasLayer/TextureBooth/HBoxContainer/IconShop,
	$CanvasLayer/TextureBooth/HBoxContainer/IconStats
]
@onready var current_nav_icon := $CanvasLayer/TextureBooth/HBoxContainer/IconVault
var can_input := false
var buttons : Array[Button] = [null]
var selected_button := 0
var current_stand := Screens.Default
var can_quit := true
var current_focus : FocusType = FocusType.Screens

func _ready():
	for s : Control in screen_nodes:
		s.visible = true
	var i := 0
	for b : Button in navigation_icons:
		b.connect("pressed", go_to_screen.bind(SCREENS_ORDER[i]))
		i += 1
	current_nav_icon.is_current_screen = true
	set_screen_infos(Screens.Default, true)
	set_focus_to(FocusType.Screens)
	$CanvasLayer/ScreenTransition.end_screen_transition()
	await get_tree().create_timer(0.5).timeout
	can_input = true

func _process(_delta):
	if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("special"):
		if current_focus == FocusType.ScreenOptions:
			set_focus_to(FocusType.Screens) 
		elif current_focus == FocusType.Screens:
			quit_to_menu()

func set_focus_to(new_focus : FocusType):
	current_focus = new_focus
	if new_focus == FocusType.Screens:
		current_nav_icon.grab_focus()
	elif new_focus == FocusType.ScreenOptions:
		pass
		#current_screen.grab_control_node.grab_focus()

func _on_exit_progress_bar_bar_filled():
	quit_to_menu()

func set_screen_infos(index : int, animated_infos := false):
	current_stand = index
	vendor.texture = VENDOR_TEXTURES[index]
	vendor.size = VENDOR_SIZES[index]
	stand_name.text = STAND_NAMES[index]
	current_screen = screen_nodes[index]
	if animated_infos:
		vendor.position = VENDOR_POSITIONS[index]
		for s : Control in screen_nodes:
			if s == current_screen:
				s.modulate = Color.WHITE
			else:
				s.modulate = Color.TRANSPARENT

func go_to_screen(new_screen : Screens):
	if current_stand == new_screen:
		return
	const TRANS_TIME := 1.5
	const N_TRANS_TIME := 1.0
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_QUART)
	var index : int = int(new_screen)
	current_nav_icon.is_current_screen = false
	current_nav_icon = navigation_icons[index]
	current_nav_icon.is_current_screen = true
	tween.tween_property(vendor, "position", Vector2(
		2200.0, vendor.position.y), TRANS_TIME)
	tween.tween_property(stand_name, "position", Vector2(516, 1300), N_TRANS_TIME)
	tween.tween_property(current_screen, "modulate", Color.TRANSPARENT, 0.8)
	await tween.finished
	set_screen_infos(index)
	vendor.position = Vector2(
		2200.0,
		VENDOR_POSITIONS[index].y
	)
	tween = create_tween().set_parallel().set_trans(Tween.TRANS_SPRING)
	tween.tween_property(vendor, "position", VENDOR_POSITIONS[index], TRANS_TIME)
	tween.tween_property(stand_name, "position", Vector2(516, 855), N_TRANS_TIME)
	tween.tween_property(current_screen, "modulate", Color.WHITE, 0.8)
	set_focus_to(FocusType.ScreenOptions)

func quit_to_menu():
	if not can_quit:
		return
	can_quit = false
	$CanvasLayer/ScreenTransition.start_screen_transition()
	await $CanvasLayer/ScreenTransition.HalfScreenTransitionFinished
	if get_tree() != null:
		get_tree().change_scene_to_file(MAIN_MENU)

func _on_button_back_pressed():
	quit_to_menu()
