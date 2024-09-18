extends Line2D
class_name TrailEffect

const MAX_POINT_DELAY := 0.025
const MAX_DISTANCE_TO_BREAK := pow(250, 2.0)

@export var max_points : int = 300

@onready var curve := Curve2D.new()
@onready var parent_obj : Node2D = get_parent()
var point_delay := 0.0
#var remove_point_delay := 0.0
var last_point : Vector2

func _process(delta : float):
	point_delay += delta
	#remove_point_delay += delta
	if point_delay < MAX_POINT_DELAY:
		return
	point_delay = 0.0
	var dist_to_new_point := last_point.distance_squared_to(parent_obj.position)
	if dist_to_new_point > MAX_DISTANCE_TO_BREAK:
		create_duplicate()
		curve.clear_points()
	elif dist_to_new_point < 100:
		if curve.point_count > 0:
			curve.remove_point(0)
			points = curve.get_baked_points()
		return
	last_point = parent_obj.position
	curve.add_point(last_point)
	#if len(curve) > 0 and remove_point_delay > MAX_REMOVE_POINT_DELAY: 
	if curve.get_baked_points().size() > max_points:
		curve.remove_point(0)
	points = curve.get_baked_points()

func create_duplicate():
	var duplicate : TrailEffect = create_trail()
	duplicate.points = points
	duplicate.modulate = modulate
	duplicate.position = position
	parent_obj.add_child(duplicate)
	duplicate.stop()
	points.clear()

func stop():
	set_process(false)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 3.0)
	await tween.finished
	queue_free()

static func create_trail() -> TrailEffect:
	return preload("res://scenes/Utilities/TrailEffect.tscn").instantiate()
