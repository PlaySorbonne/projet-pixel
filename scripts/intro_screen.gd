extends CanvasLayer


const NEXT_SCREEN = preload("res://scenes/Menus/MenuPersistent.tscn")

var transition_duration := 0.5
var transition_started := true

func _ready():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	RenderingServer.set_default_clear_color(Color.BLACK)
	$AnimationPlayer.play("idle")
	$Main/ScreenTransition.end_screen_transition(transition_duration)
	get_tree().create_timer(1.00).timeout
	transition_started = false
	# apply user settings
	SettingsScreen.load_settings_data()

func _input(event):
	if transition_started:
		return
	if event.is_pressed():
		transition_started = true
		$Main/ScreenTransition.start_screen_transition(transition_duration)
		await get_tree().create_timer(transition_duration).timeout
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_packed(NEXT_SCREEN)
