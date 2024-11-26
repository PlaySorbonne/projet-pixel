extends Control
class_name PauseMenu

@onready var pause_menu_buttons := [$ButtonContinue, $ButtonSettings, $ButtonQuit]
var button_tween : Tween = null
var focused_button : int = 0

var can_pause_game := true

func _ready():
	visible = false
	set_process_input(false)
	modulate = Color.TRANSPARENT
	for b : Button in pause_menu_buttons:
		b.modulate = Color.WEB_GRAY

func set_pause_menu_buttons_state(new_state : bool):
	for b : Button in pause_menu_buttons:
		b.disabled = not new_state

func focus_button(fb : int):
	reset_focus()
	focused_button = fb
	button_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_loops()
	pause_menu_buttons[fb].modulate = Color.WHITE
	button_tween.tween_property(
		pause_menu_buttons[fb], "scale", Vector2(1.3, 1.3), 0.4)
	button_tween.tween_property(
		pause_menu_buttons[fb], "scale", Vector2(1.15, 1.15), 0.3)

func reset_focus():
	if button_tween != null:
		button_tween.kill()
		button_tween = null
	var current_button : Button = pause_menu_buttons[focused_button]
	current_button.scale = Vector2.ONE
	current_button.modulate = Color.WEB_GRAY

func confirm_button():
	match focused_button:
		0:
			_on_button_continue_pressed()
		1:
			_on_button_settings_pressed()
		2:
			_on_button_quit_pressed()

func enter_pause():
	if not can_pause_game:
		return
	get_tree().paused = true
	set_process_input(true)
	set_pause_menu_buttons_state(true)
	visible = true
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	focus_button(0)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("down"):
		var fb : int = focused_button + 1
		if fb >= len(pause_menu_buttons):
			fb = 0
		focus_button(fb)
	if Input.is_action_just_pressed("up"):
		var fb : int = focused_button - 1
		if fb < 0:
			fb = len(pause_menu_buttons) - 1
		focus_button(fb)
	if Input.is_action_just_pressed("jump"):
		confirm_button()

func screen_transition(new_height : float):
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS
	).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "position", Vector2(position.x, new_height), 2.0)

func _on_settings_screen_button_back_pressed():
	screen_transition(0.0)
	set_pause_menu_buttons_state(true)

func _on_button_continue_pressed():
	set_pause_menu_buttons_state(false)
	$ButtonContinue.release_focus()
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.3)
	await tween.finished
	visible = false
	get_tree().paused = false
	set_process_input(false)

func _on_button_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Menus/MenuPersistent.tscn")

func _on_button_settings_pressed():
	$ButtonSettings.release_focus()
	set_pause_menu_buttons_state(false)
	screen_transition(-1300.0)
