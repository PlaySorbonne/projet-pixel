extends TextureProgressBar
class_name HealthBarUnit

signal unit_removed
signal animation_finished

const VAL_TO_PROGRESS = [0.0, 0.0, 2.02, 2.92, 3.83, 5.0]
const TIP_POS_COEFF := 20.0
const PROGRESS_TIP_TEXTURE = preload("res://scenes/Menus/GameUI/texture_progress_tip.tscn")

@export var health : int = 0
@export_color_no_alpha var default_health_color = Color(0.812, 0.0, 0.0):
	set(value):
		default_health_color = value
		self_modulate = value
		$TextureProgressTip.modulate = value
var visible_at_ready := false
var tips : Array[TextureRect] = []

func _ready():
	visible = visible_at_ready

func set_health_value(new_val : int):
	health = new_val
	_update_healthbar()

func setup_damage(val : int) -> void:
	for h in range(health, health-val, -1):
		var health_slot := PROGRESS_TIP_TEXTURE.instantiate()
		health_slot.modulate = Color.WHITE
		health_slot.position = Vector2(TIP_POS_COEFF*(h-1), 0.0)
		add_child(health_slot)
		tips.append(health_slot)
	health -= val
	_update_healthbar()

func damage(val : int, delay := 0) -> bool:
	if check_remove():
		return true
	for i in range(val):
		tips.pop_front().queue_free()
	return check_remove()

func check_remove() -> bool:
	if health == 0 and tips.size() == 0:
		remove_unit()
		return true
	return false

func heal_effect(val : int, delay : float) -> void:
	var new_tips : Array[TextureRect] = []
	var new_health : int = min(health+val, 5)
	for h in range(health, new_health):
		var health_slot := PROGRESS_TIP_TEXTURE.instantiate()
		health_slot.modulate = Color.AQUA
		health_slot.position = Vector2(TIP_POS_COEFF*h, 0.0)
		add_child(health_slot)
		new_tips.append(health_slot)
	health = new_health
	_update_healthbar()
	await get_tree().create_timer(delay).timeout
	var tween := create_tween()
	for s : TextureRect in new_tips:
		tween.tween_property(s, "modulate", Color.TRANSPARENT, 0.1)
	await tween.finished
	for s : TextureRect in new_tips:
		s.queue_free()

func _update_healthbar():
	value = VAL_TO_PROGRESS[health]
	if health == 0 or health == 5:
		$TextureProgressTip.visible = false
	else:
		$TextureProgressTip.visible = true
		$TextureProgressTip.position.x = TIP_POS_COEFF * health - 20.0

func remove_unit():
	var tween := create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(scale.x, 0.0), 0.5)
	await tween.finished
	emit_signal("unit_removed")
	queue_free()

func add_unit(delay := 0):
	var h := health
	set_health_value(0)
	scale = Vector2(1.0, 0.0)
	visible = true
	var tween := create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(scale.x, 1.0), 0.3)
	await get_tree().create_timer(0.1).timeout
	heal_effect(h,  0.1 * delay)

func add_unit_no_anim():
	scale = Vector2.ONE
	visible = true
	visible_at_ready = true
	set_health_value(health)
