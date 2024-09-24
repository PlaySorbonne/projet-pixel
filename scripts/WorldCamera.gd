extends Camera2D
class_name WorldCamera

@export var move_speed := 5.0
@export var zoom_speed := 0.25
@export var min_zoom := 0.5
@export var max_zoom := 1.1
@export var margin := Vector2(400.0, 200.0)

var min_distance = 300 # Distance minimale avant de commencer à zoomer
var max_distance = 1000 # Distance maximale pour le dézoom

@onready var screen_size := get_viewport_rect().size

func _ready():
	GameInfos.camera = self
	if not GameInfos.game_started:
		$FreezeFrame.queue_free()
		$CameraUtils.queue_free()
		$UI_hint_for_level_design.queue_free()

static func add_target(t : Node2D):
	if not t in GameInfos.tracked_targets:
		GameInfos.tracked_targets.append(t)

static func remove_target(t : Node2D):
	if t in GameInfos.tracked_targets:
		GameInfos.tracked_targets.erase(t)
	
"""
func _process(delta : float):
	return
	if not GameInfos.tracked_targets:
		return
	
	# adjust pos
	var p := Vector2.ZERO
	for target : Node2D in GameInfos.tracked_targets:
		p += target.position
	p /= GameInfos.tracked_targets.size()
	position = lerp(position, p, move_speed * delta)
	
	# adjust zoom
	var r := Rect2(position, Vector2.ZERO)
	for target in GameInfos.tracked_targets:
		r = r.expand(target.position)
	r = r.grow_individual(margin.x, margin.y, margin.x, margin.y)
	#var d : float = max(r.size.x, r.size.y)
	var z : float
	if r.size.x > r.size.y * screen_size.aspect():
		z = clamp(screen_size.x / r.size.x, min_zoom, max_zoom)
	else:
		z = clamp(screen_size.y / r.size.y, min_zoom, max_zoom)
	zoom = lerp(zoom, Vector2.ONE * z, zoom_speed * delta)
"""
