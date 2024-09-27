extends Control
class_name ArtworkEnsemble

const OFFSET := 40.0

func _ready():
	set_children_hovering()

func set_children_hovering():
	for c : Control in get_children():
		if c.is_in_group("hover"):
			start_hovering_with_delay(c)

func start_hovering_with_delay(c : TextureRect):
	await get_tree().create_timer(randf_range(0.0, 2.0)).timeout
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var current_pos := c.position
	var offset_vector : Vector2
	if randi() % 2 == 0:
		offset_vector = Vector2(0.0, -OFFSET)
	else:
		offset_vector = Vector2(0.0,  OFFSET)
	var mult = randf_range(0.75, 1.5)
	var duration := randf_range(2.0, 3.0)
	tween.tween_property(c, "position", current_pos+offset_vector*mult, duration*mult)
	tween.tween_property(c, "position", current_pos, duration*mult)
