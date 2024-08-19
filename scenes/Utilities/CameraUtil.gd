extends Node
class_name CameraUtils

@onready var camera : Camera2D = get_parent()


func _ready():
	GameInfos.camera_utils = self
	$Shaker.object = camera

func quick_zoom(tmp_zoom : Vector2, obj_pos : Vector2, duration : float, interp_duration : float):
	var default_pos : Vector2 = camera.global_position
	interp_pos(obj_pos, interp_duration)
	var default_zoom : Vector2 = camera.zoom
	var tween : Tween = interp_zoom(tmp_zoom, interp_duration)
	await tween.finished
	await get_tree().create_timer(duration).timeout
	interp_zoom(default_zoom, interp_duration)
	interp_pos(default_pos, interp_duration)

func interp_pos(new_pos : Vector2, duration : float, ease := Tween.EASE_OUT,
	trans := Tween.TRANS_LINEAR) -> Tween:
	var tween : Tween = create_tween().set_ease(ease).set_trans(trans)
	tween.tween_property(camera, "global_position", new_pos, duration)
	return tween

func interp_zoom(new_zoom : Vector2, duration : float, ease := Tween.EASE_OUT, 
	trans := Tween.TRANS_LINEAR) -> Tween:
	var tween : Tween = create_tween().set_ease(ease).set_trans(trans)
	tween.tween_property(camera, "zoom", new_zoom, duration)
	return tween

func shake(duration_n = 0.2, frequency_n = 15, amplitude_n = 30, priority_n = 0):
	$Shaker.shake(duration_n, frequency_n, amplitude_n, priority_n)
