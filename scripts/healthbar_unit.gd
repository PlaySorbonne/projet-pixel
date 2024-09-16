extends TextureProgressBar

const VAL_TO_PROGRESS = [0.0, 0.0, 1.5, 2.3, 3.3, 4.5]
const DEFAULT_TIP_COLOR = Color(0.812, 0.0, 0.0)
const VAL_TO_TIP_POS_COEFF := 20.0

@export var health : int = 5


func set_health_value(new_val : int):
	health = new_val
	_update_healthbar()

func damage(val : int):
	for _i in val:
		health -= 1
		_update_healthbar()
		await get_tree().create_timer(0.1).timeout
	if health > 0:
		hit_effect()

func _update_healthbar():
	value = VAL_TO_PROGRESS[health]
	if health == 0.0:
		$TextureProgressTip.visible = false
	else:
		$TextureProgressTip.visible = true
		$TextureProgressTip.position.x = DEFAULT_TIP_COLOR * health

func hit_effect(number := 3, time := 0.2, hit_color := Color.WHITE):
	for _i in range(number):
		$TextureProgressTip.modulate = hit_color
		await get_tree().create_timer(time).timeout
		$TextureProgressTip.modulate = DEFAULT_TIP_COLOR
		await get_tree().create_timer(time).timeout
