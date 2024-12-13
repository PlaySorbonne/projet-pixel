@tool
extends Node
class_name WrapAround


const MAX_UPDATE_TIME := 0.25

@export var top_limit    := -500.0:
	set(value):
		top_limit = value
		$SpriteUp.position = Vector2(0, top_limit)
		$SpriteUpOffset.position = $SpriteUp.position + Vector2(0, teleporter_offset)
@export var bottom_limit :=  500.0:
	set(value):
		bottom_limit = value
		$SpriteDown.position = Vector2(0, bottom_limit)
		$SpriteDownOffset.position = $SpriteDown.position - Vector2(0, teleporter_offset)
@export var left_limit   := -500.0:
	set(value):
		left_limit = value
		$SpriteLeft.position = Vector2(left_limit, 0)
		$SpriteLeftOffset.position = $SpriteLeft.position + Vector2(teleporter_offset, 0)
@export var right_limit  :=  500.0:
	set(value):
		right_limit = value
		$SpriteRight.position = Vector2(right_limit, 0)
		$SpriteRightOffset.position = $SpriteRight.position - Vector2(teleporter_offset, 0)
@export var teleporter_offset := 50.0:
	set(value):
		teleporter_offset = value
		top_limit = top_limit
		bottom_limit = bottom_limit
		right_limit = right_limit
		left_limit = left_limit

var update_time := 0.0
@onready var top_tp_target    := top_limit + teleporter_offset
@onready var bottom_tp_target := bottom_limit - teleporter_offset
@onready var left_tp_target   := left_limit + teleporter_offset
@onready var right_tp_target  := right_limit - teleporter_offset
 

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	for c : Node2D in get_children():
		c.queue_free()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	update_time += delta
	if update_time <= MAX_UPDATE_TIME or not GameInfos.game_started:
		return
	update_time = 0.0
	for p : PlayerCharacter in GameInfos.players.values():
		check_obj_position(p, false)
	if not GameInfos.anime_box.following_weeb:
		check_obj_position(GameInfos.anime_box, true)

func check_obj_position(obj : Node2D, force_pos := false) -> void:
	var obj_pos := obj.global_position
	if   obj_pos.x > right_limit:
		set_pos(obj, Vector2(left_tp_target, obj_pos.y), force_pos)
	elif obj_pos.x < left_limit:
		set_pos(obj, Vector2(right_tp_target, obj_pos.y), force_pos)
	if   obj_pos.y > bottom_limit:
		set_pos(obj, Vector2(obj_pos.x, top_tp_target), force_pos)
	elif obj_pos.y < top_limit:
		set_pos(obj, Vector2(obj_pos.x, bottom_tp_target), force_pos)

func set_pos(obj : Node2D, new_pos : Vector2, force_pos := false) -> void:
	if force_pos:
		obj.force_position(new_pos)
	else:
		obj.global_position = new_pos
