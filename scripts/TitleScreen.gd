extends Control

signal ButtonStartPressed
signal ButtonVaultPressed
signal ButtonSettingsPressed
signal ButtonCreditsPressed
signal ButtonSelected

const position_x_normal := 250.0
const position_x_selected := 300.0
const button_colors := [Color.RED, Color.GOLD, Color.DARK_CYAN, Color.ROYAL_BLUE]

var signals := [
	"ButtonStartPressed",
	"ButtonVaultPressed",
	"ButtonSettingsPressed",
	"ButtonCreditsPressed"
]
@onready var pointers := [
	$Pointer0,
	$Pointer1,
	$Pointer2,
	$Pointer3
]
@onready var buttons := [
	$StartButton,
	$Vault,
	$Settings,
	$Credits
]
var selected_button := 1
var can_input := true
var button_movement_val := 0.0

func _ready():
	for p : TextureRect in pointers:
		p.modulate = Color.TRANSPARENT
	select_button(0)

func _on_start_button_pressed():
	select_button(0)
	confirm_with_delay()

func _on_vault_pressed():
	select_button(1)
	confirm_with_delay()

func _on_settings_pressed():
	select_button(2)
	confirm_with_delay()

func _on_credits_pressed():
	select_button(3)
	confirm_with_delay()

func confirm_with_delay():
	await self.ButtonSelected
	confirm_button()

func _process(delta : float):
	if not can_input:
		return
	var b : Button = buttons[selected_button]
	button_movement_val += delta
	b.anchor_left = cos(button_movement_val * 6) * 0.01 + 0.01
	if Input.is_action_just_pressed("down") or Input.is_action_just_pressed("right"):
		var new_button := selected_button + 1
		if new_button >= len(buttons):
			new_button = 0
		select_button(new_button)
	elif Input.is_action_just_pressed("up") or Input.is_action_just_pressed("left"):
		var new_button := selected_button - 1
		if new_button < 0:
			new_button = len(buttons) - 1
		select_button(new_button)
	elif Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("special"):
		confirm_button()

func select_button(button_number : int):
	if selected_button == button_number:
		get_tree().create_timer(0.1).timeout
		emit_signal("ButtonSelected")
		return
	var old_button : Button = buttons[selected_button]
	var new_button : Button = buttons[button_number]
	var old_pointer : TextureRect = pointers[selected_button]
	var new_pointer : TextureRect = pointers[button_number]
	old_button.anchor_left = 0.0
	selected_button = button_number
	new_pointer.position.x = 45.0
	
	var t2 : Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	t2.tween_property(new_button, "position", Vector2(position_x_selected, new_button.position.y), 0.15)
	t2.set_parallel()
	t2.tween_property(new_button, "scale", Vector2(1.2, 1.2), 0.15)
	t2.tween_property(new_button, "modulate", button_colors[button_number], 0.15)
	t2.tween_property(old_pointer, "modulate", Color.TRANSPARENT, 0.15)
	t2.tween_property(old_pointer, "position", Vector2(45, old_pointer.position.y), 0.25)

	await get_tree().create_timer(0.05).timeout

	var t1 : Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	t1.tween_property(old_button, "position", Vector2(position_x_normal, old_button.position.y), 0.2)
	t1.set_parallel()
	t1.tween_property(old_button, "scale", Vector2.ONE, 0.2)
	t1.tween_property(old_button, "modulate", Color.WHITE, 0.2)
	t1.tween_property(new_pointer, "modulate", button_colors[button_number], 0.2)
	t1.tween_property(new_pointer, "position", Vector2(105, new_pointer.position.y), 0.2)
	
	get_tree().create_timer(0.2).timeout
	emit_signal("ButtonSelected")


func button_blink(button_number : int, number_of_blinks := 3):
	var button : Button = buttons[button_number]
	for _i in range(number_of_blinks):
		button.modulate = Color.WHITE
		await get_tree().create_timer(0.1).timeout
		button.modulate = button_colors[button_number]
		await get_tree().create_timer(0.1).timeout

func confirm_button():
	#var b : Button = buttons[selected_button]
	button_blink(selected_button)
	can_input = false
	emit_signal(signals[selected_button])
