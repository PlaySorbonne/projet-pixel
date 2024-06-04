extends Control

signal HalfScreenTransitionFinished
signal ScreenTransitionFinished

var tween : Tween

func _ready():
	tween = get_tree().create_tween()

func screen_transition(duration : float, color : Color):
	start_screen_transition(duration/2.0, color)
	await self.HalfScreenTransitionFinished
	end_screen_transition(duration/2.0, color)

func start_screen_transition(duration : float, color : Color):
	$ColorRect.color = color
	tween.tween_property($ColorRect, "color", color, duration)
	await get_tree().create_timer(duration).timeout
	emit_signal("HalfScreenTransitionFinished")

func end_screen_transition(duration : float, color : Color):
	$ColorRect.color = color
	tween.tween_property($ColorRect, "color", color, duration)
	await get_tree().create_timer(duration).timeout
	emit_signal("ScreenTransitionFinished")
