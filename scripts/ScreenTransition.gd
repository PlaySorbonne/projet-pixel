@tool
class_name ScreenTransition
extends Control

signal HalfScreenTransitionFinished
signal ScreenTransitionFinished

@export var default_color : Color : set=_set_default_color
@export var default_duration : float = 2.0
@export var default_is_opaque : bool = true : set=_set_is_opaque


func _set_is_opaque(new_opaque : bool):
	default_is_opaque = new_opaque
	if new_opaque:
		$ColorRect.modulate.a = 1.0
	else:
		$ColorRect.modulate.a = 0.0

func _set_default_color(new_color : Color):
	default_color = new_color
	$ColorRect.color = new_color

func new_screen_transition(duration : float = default_duration, color : Color = default_color):
	if $ColorRect.modulate.a <= 0.0:
		start_screen_transition(duration/2.0, color)
		await self.HalfScreenTransitionFinished
	end_screen_transition(duration/2.0, color)

func start_screen_transition(duration : float = default_duration/2.0, color : Color = default_color):
	$ColorRect.color = color
	$ColorRect.modulate = Color.TRANSPARENT
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	var tween : Tween = get_tree().create_tween()
	tween.tween_property($ColorRect, "modulate", Color.WHITE, duration)
	await get_tree().create_timer(duration).timeout
	emit_signal("HalfScreenTransitionFinished")

func end_screen_transition(duration : float = default_duration/2.0, color : Color = default_color):
	$ColorRect.color = color
	visible = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tween : Tween = get_tree().create_tween()
	tween.tween_property($ColorRect, "modulate", Color.TRANSPARENT, duration)
	await get_tree().create_timer(duration).timeout
	emit_signal("ScreenTransitionFinished")
