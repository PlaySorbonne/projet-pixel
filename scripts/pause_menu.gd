extends Control
class_name PauseMenu

@onready var pause_menu_buttons := [$ButtonContinue, $ButtonSettings, $ButtonQuit]

func _ready():
	visible = false
	modulate = Color.TRANSPARENT

func set_pause_menu_buttons_state(new_state : bool):
	for b : Button in pause_menu_buttons:
		b.disabled = not new_state

func enter_pause():
	get_tree().paused = true
	set_pause_menu_buttons_state(true)
	visible = true
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)

func screen_transition(new_height : float):
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "position", Vector2(position.x, new_height), 1.0)

func _on_settings_screen_button_back_pressed():
	screen_transition(0.0)

func _on_button_continue_pressed():
	set_pause_menu_buttons_state(false)
	$ButtonContinue.release_focus()
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.3)
	await tween.finished
	visible = false
	get_tree().paused = false

func _on_button_quit_pressed():
	get_tree().change_scene_to_file("res://scenes/Menus/MenuPersistent.tscn")

func _on_button_settings_pressed():
	$ButtonSettings.release_focus()
	screen_transition(-1300.0)
