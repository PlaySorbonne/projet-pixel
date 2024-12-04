extends Node
class_name CameraUtils

enum PARAMS {brightness, contrast, saturation, redVal, greenVal, blueVal, tint_color, tint_effect_factor}

@onready var camera : Camera2D = get_parent()
@onready var color_manipulator := $CanvasLayer/ColorManipulator
@onready var default_pos : Vector2 = camera.global_position
@onready var default_zoom : Vector2 = camera.zoom
var default_param_values := {
	"brightness" : 0.0,
	"contrast" : 1.0,
	"saturation" : 1.0,
	"redVal" : 1.0,
	"greenVal" : 1.0,
	"blueVal" : 1.0,
	"tintColor" : Color(1.0, 1.0, 1.0, 1.0),
	"tint_effect_factor" : 1.0
}

func _ready():
	GameInfos.camera_utils = self
	$Shaker.object = camera

func quick_zoom(zoom_coeff : float, obj_pos : Vector2, duration : float, interp_duration : float):
	interp_pos(obj_pos, interp_duration)
	var tween : Tween = interp_zoom(default_zoom * zoom_coeff, interp_duration)
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

func set_screen_param(param : PARAMS, value : float = 0.0):
	$CanvasLayer/ColorManipulator.material.set_shader_param(str(param), value)

func _flash_color_param(param : String, val : float, duration : float, go_back : bool):
	if not go_back:
		default_param_values[param] = val
	var go_back_value : float = default_param_values[param]
	var param_str : String = "material:shader_parameter/" + param
	var tween := create_tween()
	tween.tween_property(color_manipulator, param_str, val, duration)
	if go_back:
		tween.tween_property(color_manipulator, param_str, go_back_value, duration)

func flash_constrast(val : float, duration : float, go_back := true):
	_flash_color_param("contrast", val, duration, go_back)

func flash_saturation(val : float, duration : float, go_back := true):
	_flash_color_param("saturation", val, duration, go_back)
