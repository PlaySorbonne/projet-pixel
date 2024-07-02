extends ProgressBar

signal player_joined
signal player_cancelled

var is_keyboard := true
var player_device = -1
var tween : Tween

func _ready():
	$Timer.start()
	tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "value", 1.0, $Timer.wait_time)

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
	if tween.is_valid():
		tween.stop()
	$Timer.stop()
	emit_signal("player_cancelled", player_device, is_keyboard)
	await get_tree().create_timer(0.01).timeout
	queue_free()

func confirm_join():
	emit_signal("player_joined", player_device, is_keyboard)
	await get_tree().create_timer(0.01).timeout
	queue_free()
