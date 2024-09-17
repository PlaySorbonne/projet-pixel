extends TextureProgressBar

const VAL_TO_PROGRESS = [0.0, 0.0, 1.5, 2.3, 3.3, 4.5]
const DEFAULT_TIP_COLOR = Color(0.812, 0.0, 0.0)
const TIP_POS_COEFF := 20.0
const PROGRESS_TIP_TEXTURE = preload("res://scenes/Menus/GameUI/texture_progress_tip.tscn")

@export var health : int = 5


func set_health_value(new_val : int):
	health = new_val
	_update_healthbar()

func damage(val : int):
	var new_tips : Array[TextureRect] = []
	for h in range(health, health-val, -1):
		var health_slot := PROGRESS_TIP_TEXTURE.instantiate()
		health_slot.modulate = Color.WHITE
		health_slot.position = Vector2(TIP_POS_COEFF*h, 0.0)
		add_child(health_slot)
		new_tips.append(health_slot)
	health -= val
	_update_healthbar()
	hit_effect(new_tips)

func _update_healthbar():
	value = VAL_TO_PROGRESS[health]
	if health == 0.0:
		$TextureProgressTip.visible = false
	else:
		$TextureProgressTip.visible = true
		$TextureProgressTip.position.x = DEFAULT_TIP_COLOR * health

func hit_effect(lost_slots : Array[TextureRect]):
	for s : TextureRect in lost_slots:
		await get_tree().create_timer(0.25).timeout
		s.queue_free()
