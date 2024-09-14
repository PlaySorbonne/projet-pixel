extends Line2D
class_name TrailEffect

@export var max_points : int = 200

@onready var curve := Curve2D.new()
@onready var parent_obj : Node2D = get_parent()
var point_delay := 0.0
var last_point : Vector2

func _process(delta : float):
	point_delay += delta
	if point_delay < 0.01:
		return
	point_delay = 0.0
	if last_point.distance_squared_to(parent_obj.position) > 10000.0:
		create_duplicate()
	last_point = parent_obj.position
	curve.add_point(last_point)
	if curve.get_baked_points().size() > max_points:
		curve.remove_point(0)
	points = curve.get_baked_points()

func create_duplicate():
	var duplicate : TrailEffect = create_trail()
	duplicate.points = points
	duplicate.modulate = modulate
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
