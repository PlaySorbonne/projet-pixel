extends Area2D
class_name Hitbox

var damage := 1
var intensity = 1
var team := 0
var can_multi_hit := false
var delay_between_hits := 0.4

static func new_hitbox(parent : FighterCharacter, hit_damage : int, hitbox_location : Vector2,
duration : float, attached_to_character := true, hit_intensity := 1, size := Vector2.ONE,
can_multi_hit := false, delay_between_hits := 0.4) -> Hitbox:
	var my_scene: PackedScene = load("res://scripts/AttackHitbox.gd")
	var hitbox : Hitbox = my_scene.instantiate()
	hitbox.team = parent.team
	hitbox.damage = hit_damage
	hitbox.intensity = hit_intensity
	if attached_to_character:
		parent.add_child(hitbox)
	else:
		GameInfos.world.add_child(hitbox)
	hitbox.position = hitbox_location
	hitbox.can_multi_hit = can_multi_hit
	hitbox.delay_between_hits = delay_between_hits
	hitbox.scale = size
	if duration > 0.0:
		hitbox.set_hitbox_lifetime(duration)
	return hitbox

func set_hitbox_lifetime(time : float):
	$Timer.start(time)

func end_hitbox():
	queue_free()

func _on_body_entered(body):
	if body.has_method("hit") and body.team != team:
		body.hit(damage)

func _on_timer_timeout():
	end_hitbox()
