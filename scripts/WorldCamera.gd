extends Camera2D

@export var move_speed := 0.5
@export var zoom_speed := 0.05
@export var min_zoom := 1.75
@export var max_zoom := 5.0
@export var margin := Vector2(400.0, 200.0)

var targets : Array = []

func _ready():
	GameInfos.camera = self
