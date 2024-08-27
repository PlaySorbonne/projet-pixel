extends Control

signal ButtonStartPressed

const position_x_normal := 250.0
const position_x_selected := 300.0
const button_colors := [Color.DARK_RED, Color.GOLD, Color.DARK_CYAN, Color.ROYAL_BLUE]

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

func _ready():
	for p : TextureRect in pointers:
		p.modulate = Color.TRANSPARENT
	select_button(0)

func _on_start_button_pressed():
	emit_signal("ButtonStartPressed")
	$StartButton.disabled = true


func _process(delta):
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
	var old_button : Button = buttons[selected_button]
	var new_button : Button = buttons[button_number]
	var old_pointer : TextureRect = pointers[selected_button]
	var new_pointer : TextureRect = pointers[button_number]
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

func confirm_button():
	var b : Button = buttons[selected_button]
	
