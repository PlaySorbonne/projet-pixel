extends Control

signal ButtonStartPressed
signal ButtonVaultPressed
signal ButtonSettingsPressed
signal ButtonCreditsPressed
signal ButtonTutorialPressed
signal ButtonSelected

const position_x_normal := 250.0
const position_x_selected := 300.0
const button_colors := [Color.RED, Color.GOLD, Color.DARK_CYAN, Color.ROYAL_BLUE, Color.BLUE_VIOLET]

@onready var positions_x_normal : Array[int] = [
	250,
	250,
	250,
	250,
	1250
]

@export var buttons_sfx : Array[AudioStream] = [
	preload("res://resources/audio/voices/narrator/play.wav"),
	preload("res://resources/audio/voices/narrator/vault.wav"),
	preload("res://resources/audio/voices/narrator/settings.wav"),
	preload("res://resources/audio/voices/narrator/credits.wav"),
	preload("res://resources/audio/voices/narrator/play.wav") # TODO: change sound
]

var signals := [
	"ButtonStartPressed",
	"ButtonVaultPressed",
	"ButtonSettingsPressed",
	"ButtonCreditsPressed",
	"ButtonTutorialPressed"
]
@onready var pointers := [
	$Pointer0,
	$Pointer1,
	$Pointer2,
	$Pointer3,
	$Pointer4
]
@onready var buttons := [
	$StartButton,
	$Vault,
	$Settings,
	$Credits,
	$Tutorial
]
var selected_button := 1
var can_input := false
var button_movement_val := 0.0

func _ready():
	for p : TextureRect in pointers:
		p.modulate = Color.TRANSPARENT
	select_button(0)

func set_narrator_sound(stream : AudioStream):
	$AudioNarrator.stream = stream
	$AudioNarrator.play()

func _on_start_button_pressed():
	select_button(0)
	confirm_with_delay()
	set_narrator_sound(buttons_sfx[0])

func _on_vault_pressed():
	select_button(1)
	confirm_with_delay()
	set_narrator_sound(buttons_sfx[1])

func _on_settings_pressed():
	select_button(2)
	confirm_with_delay()
	set_narrator_sound(buttons_sfx[2])

func _on_credits_pressed():
	select_button(3)
	confirm_with_delay()
	set_narrator_sound(buttons_sfx[3])
	
func _on_tutorial_pressed() -> void:
	select_button(4)
	confirm_with_delay()
	set_narrator_sound(buttons_sfx[4])

func confirm_with_delay():
	await get_tree().create_timer(0.2).timeout
	confirm_button()
	
func reset_state():
	can_input = true

func _process(delta : float):
	if not can_input:
		return
	var b : Button = buttons[selected_button]
	button_movement_val += delta
	b.anchor_left = cos(button_movement_val * 9) * 0.01 + 0.01
	if Input.is_action_just_pressed("down") or Input.is_action_just_pressed("right"):
		$AudioArrowDown.play(0.0)
		var new_button : = selected_button + 1
		if new_button >= len(buttons):
			new_button = 0
		select_button(new_button)
	elif Input.is_action_just_pressed("up") or Input.is_action_just_pressed("left"):
		$AudioArrowUp.play(0.0)
		var new_button := selected_button - 1
		if new_button < 0:
			new_button = len(buttons) - 1
		select_button(new_button)
	elif Input.is_action_just_pressed("ui_accept"):
		confirm_button()
		b.emit_signal("pressed")

func select_button(button_number : int):
	
	# Bouton  déja séléctionné
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
	new_pointer.position.x = positions_x_normal[button_number] - 100
	
	# Mise en avant nouveau bouton
	var t2 : Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	t2.tween_property(new_button, "position", Vector2(positions_x_normal[button_number] + 50, new_button.position.y), 0.15)
	t2.set_parallel()
	t2.tween_property(new_button, "scale", Vector2(1.2, 1.2), 0.15)
	t2.tween_property(new_button, "modulate", button_colors[button_number], 0.15)
	
	# Retrait ancien pointeur
	t2.tween_property(old_pointer, "modulate", Color.TRANSPARENT, 0.15)
	if button_number < 4:
		t2.tween_property(old_pointer, "position", Vector2(positions_x_normal[button_number] - 100, old_pointer.position.y), 0.25)
	else:
		t2.tween_property(old_pointer, "position", Vector2(positions_x_normal[button_number - 1] - 100, old_pointer.position.y), 0.25)

	await get_tree().create_timer(0.05).timeout

	# Retrait ancien bouton
	var t1 : Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	if old_button == $Tutorial:
		t1.tween_property(old_button, "position", Vector2(positions_x_normal[4], old_button.position.y), 0.2)
	else:
		if button_number == 4:
			t1.tween_property(old_button, "position", Vector2(positions_x_normal[button_number - 1], old_button.position.y), 0.2)
		else:
			t1.tween_property(old_button, "position", Vector2(positions_x_normal[button_number], old_button.position.y), 0.2)
	t1.set_parallel()
	t1.tween_property(old_button, "scale", Vector2.ONE, 0.2)
	t1.tween_property(old_button, "modulate", Color.WHITE, 0.2)
	
	# Retrait ancien pointeur
	t1.tween_property(new_pointer, "modulate", button_colors[button_number], 0.2)
	t1.tween_property(new_pointer, "position", Vector2(positions_x_normal[button_number] - 100, new_pointer.position.y), 0.2)
	
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
