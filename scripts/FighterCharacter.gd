extends CharacterBody2D
class_name FighterCharacter

signal fighter_killed_opponent
signal fighter_died

@export var max_hitpoints := 3
@export var invincibility_time := 0.2

var character_id := 0
var team := 0
var hitpoints := max_hitpoints
var alive := false
var active := false
var in_invincibility_time := false

static var number_of_characters := 0

static func add_new_character() -> int:
	number_of_characters += 1
	return number_of_characters

static func reset_character_ids() -> void:
	number_of_characters = 0

func _ready():
	visible = false
	character_id = add_new_character()
	set_physics_process(false)
	set_process_input(false)
	team = character_id # to remove if we decide to do team battles

func spawn(location : Vector2):
	hitpoints = max_hitpoints
	position = location
	scale = Vector2.ZERO
	rotation = 0
	visible = true
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2.ONE, 1.0)
	await tween.finished
	set_player_active(true)
	scale = Vector2.ONE

func set_player_active(new_activity : bool):
	$CollisionShape2D.disabled = not new_activity
	active = new_activity
	alive = new_activity
	set_physics_process(new_activity)
	set_process_input(new_activity)

func hit(damage : int, attacker : FighterCharacter = null):
	if in_invincibility_time or not alive:
		print("return")
		return
	hitpoints -= damage
	$HitEffect.trigger_hit_effect()
	if hitpoints <= 0:
		if attacker != null:
			attacker.emit_signal("fighter_killed_opponent")
		death()
	else:
		in_invincibility_time = true
		$InvincibilityTimer.start(invincibility_time)

func _on_invincibility_timer_timeout():
	in_invincibility_time = false

func death():
	if not alive:
		return
	set_player_active(false)
	var tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ZERO, 1.0)
	await tween.finished
	emit_signal("fighter_died", self)
	position = Vector2(-9999, -9999)
	visible = false
