extends Camera2D
class_name WorldCamera

@export var move_speed := 0.5
@export var zoom_speed := 0.05
@export var min_zoom := 0.5
@export var max_zoom := 1.1
@export var margin := Vector2(400.0, 200.0)

@onready var screen_size := get_viewport_rect().size
var targets : Array = []

func _ready():
	GameInfos.camera = self

func add_target(t : Node2D):
	if not t in targets:
		targets.append(t)

func remove_target(t : Node2D):
	if t in targets:
		targets.erase(t)

func _process(_delta : float):
	var true_targets : Array = GameInfos.players# + targets
	if not true_targets:
		return
	
	# adjust pos
	var p := Vector2.ZERO
	for target : Node2D in true_targets:
		p += target.position
	p /= true_targets.size()
	position = lerp(position, p, move_speed)
	
	# adjust zoom
	var r := Rect2(position, Vector2.ZERO)
	for target in true_targets:
		r = r.expand(target.position)
	r = r.grow_individual(margin.x, margin.y, margin.x, margin.y)
	#var d : float = max(r.size.x, r.size.y)
	var z : float
	if r.size.x > r.size.y * screen_size.aspect():
		z = clamp(r.size.x / screen_size.x, min_zoom, max_zoom)
	else:
		z = clamp(r.size.y / screen_size.y, min_zoom, max_zoom)
	zoom = lerp(zoom, Vector2.ONE * z, zoom_speed)
