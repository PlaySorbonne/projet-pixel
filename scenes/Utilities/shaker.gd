extends Node
class_name Shaker

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT


@export var object : Node
@export var property := "offset"
@export var reset_to_zero := true
var initial_value := Vector2.ZERO
var amplitude := 0
var priority := 0
var shaking := false
var frequency := 0.0



func shake(duration_n := 0.2, frequency_n := 15, amplitude_n := 30, priority_n := 0):
	if priority_n >= priority :
		priority = priority_n
		amplitude = amplitude_n
	shaking = true
	if reset_to_zero:
		initial_value = Vector2.ZERO
	else:
		initial_value = object.get(property)
	frequency = 1/float(frequency_n)
	_new_shake()
	await get_tree().create_timer(duration_n).timeout
	shaking = false
	_reset()

func _new_shake():
	var rand := Vector2()
	rand.x = randf_range(-amplitude, amplitude)
	rand.y = randf_range(-amplitude, amplitude)
	await _tween_shake(rand).finished
	if shaking:
		_new_shake()

func _tween_shake(new_pos : Vector2) -> Tween:
	var tween : Tween = create_tween().set_ease(EASE).set_trans(TRANS)
	tween.tween_property(object, property, initial_value + new_pos, frequency)
	return tween

func _reset():
	_tween_shake(Vector2.ZERO)
	priority = 0
	await get_tree().create_timer(2.0).timeout
