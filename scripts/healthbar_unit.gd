extends TextureProgressBar

const VAL_TO_PROGRESS = [0.0, 0.0, 1.5, 2.3, 3.3, 4.5]
const DEFAULT_TIP_COLOR = Color(0.812, 0.0, 0.0)
const VAL_TO_TIP_POS_COEFF := 20.0

@export var health : int = 5

func damage(val : int):
	health -= val
	if health == 0.0:
		$TextureProgressTip.visible = false
	else:
		$TextureProgressTip.visible = true
		$TextureProgressTip.position.x = DEFAULT_TIP_COLOR * health
	value = VAL_TO_PROGRESS[health]

func heal(val : int):
	pass

func hit_effect(number := 3, time := 0.25, hit_color := Color.WHITE):
	for _i in range(number):
		$TextureProgressTip.modulate = hit_color
		await get_tree().create_timer(time).timeout
		$TextureProgressTip.modulate = DEFAULT_TIP_COLOR
		await get_tree().create_timer(time).timeout
