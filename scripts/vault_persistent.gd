extends Node2D
class_name Vault

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
	preload("res://resources/images/characters/weeb/weeb_idle.png")
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
	$CanvasLayer/TextureBooth/IconCollection,
	$CanvasLayer/TextureBooth/IconDojo,
	$CanvasLayer/TextureBooth/IconVault,
	$CanvasLayer/TextureBooth/IconShop,
	$CanvasLayer/TextureBooth/IconStats
]
@onready var current_nav_icon := $CanvasLayer/TextureBooth/IconVault
var can_input := false
var buttons : Array[Button] = [null]
var selected_button := 0
var current_stand := Screens.Default
var can_quit := true
var current_focus : FocusType = FocusType.Screens

static var vault_canvas_layer : CanvasLayer = null
static var vault_focused_object : Control = null
static var music_player : AudioStreamPlayer = null

func _ready():
	vault_canvas_layer = $CanvasLayer
	music_player = $AudioStreamPlayer
	VaultData.load_vault_data()
	for s : VaultSubScreen in screen_nodes:
		s.visible = true
		if s != current_screen:
			s.position = Vector2(0.0, -1080)
	var i := 0
	for b : Button in navigation_icons:
		b.connect("pressed", go_to_screen.bind(SCREENS_ORDER[i]))
		i += 1
	current_nav_icon.is_current_screen = true
	$CanvasLayer/TextureBooth/LabelMoney.text = str(VaultData.vault_data["money"])
	set_screen_infos(Screens.Default, true)
	set_focus_to(FocusType.Screens)
	$CanvasLayer/ScreenTransition.end_screen_transition()
	await get_tree().create_timer(0.5).timeout
	can_input = true

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if current_focus == FocusType.ScreenOptions:
			set_focus_to(FocusType.Screens)
		else:
			set_focus_to(FocusType.ScreenOptions)

func set_focus_to(new_focus : FocusType):
	current_focus = new_focus
	if new_focus == FocusType.Screens:
		current_nav_icon.grab_focus()
	elif new_focus == FocusType.ScreenOptions:
		if current_screen.grab_control_node != null:
			current_screen.grab_control_node.grab_focus()
		else:
			current_nav_icon.grab_focus()

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
				s.position = Vector2.ZERO
			else:
				s.position = Vector2(0.0, -1080.0)

func go_to_screen(new_screen : Screens):
	if current_stand == new_screen:
		set_focus_to(FocusType.ScreenOptions)
		return
	const TRANS_TIME := 0.6
	const N_TRANS_TIME := 0.4
	const B_TRANS_TIME := 0.4
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_QUART)
	var index : int = int(new_screen)
	current_nav_icon.is_current_screen = false
	current_nav_icon = navigation_icons[index]
	current_nav_icon.is_current_screen = true
	tween.tween_property(vendor, "position", Vector2(
		2200.0, vendor.position.y), TRANS_TIME)
	tween.tween_property(stand_name, "position", Vector2(516, 1300), N_TRANS_TIME)
	tween.tween_property(current_screen, "position", Vector2(0.0, -1080.0), 
		B_TRANS_TIME)
	await tween.finished
	set_screen_infos(index)
	vendor.position = Vector2(
		2200.0,
		VENDOR_POSITIONS[index].y
	)
	tween = create_tween().set_parallel().set_trans(Tween.TRANS_SPRING)
	tween.tween_property(vendor, "position", VENDOR_POSITIONS[index], TRANS_TIME)
	tween.tween_property(stand_name, "position", Vector2(516, 855), N_TRANS_TIME)
	tween.tween_property(current_screen, "position", Vector2.ZERO, B_TRANS_TIME)
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
