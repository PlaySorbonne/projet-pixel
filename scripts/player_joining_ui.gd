extends ProgressBar

signal player_joined
signal player_cancelled

var is_keyboard := true
var player_device = -1

static var keyboard_devices : Dictionary = {}
static var controller_devices : Dictionary = {}

func _input(event):
	if not ((event is InputEventKey and is_keyboard) or (event is InputEventJoypadButton and not is_keyboard)):
		return
	if event.device != player_device:
		return
	if event.is_released():
		cancel_join()

func _on_timer_timeout():
	confirm_join()

func cancel_join():
	$Timer.stop()
	emit_signal("player_cancelled")
	await get_tree().create_timer(0.01).timeout
	queue_free()

func confirm_join():
	emit_signal("player_joined")
	await get_tree().create_timer(0.01).timeout
	queue_free()

