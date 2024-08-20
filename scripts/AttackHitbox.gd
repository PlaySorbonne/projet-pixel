extends Area2D
class_name Hitbox

const HITBOX_SCENE = preload("res://scenes/Characters/Elements/AttackHitbox.tscn")

var damage := 1
var intensity = 1
var team := 0
var can_multi_hit := false
var delay_between_hits := 0.4
var attacker : FighterCharacter
var attached_to_char : bool

static func spawn_hitbox(parent : FighterCharacter, hit_damage : int, hitbox_location : Vector2,
duration : float, attached_to_character := true, hit_intensity := 1, size := Vector2.ONE,
can_multi_hit := false, delay_between_hits := 0.4) -> Hitbox:
	var hitbox : Hitbox = HITBOX_SCENE.instantiate()
	hitbox.team = parent.team
	hitbox.damage = hit_damage
	hitbox.attacker = parent
	hitbox.intensity = hit_intensity
	if attached_to_character:
		parent.add_child(hitbox)
	else:
		GameInfos.world.add_child(hitbox)
	hitbox.position = hitbox_location
	hitbox.can_multi_hit = can_multi_hit
	hitbox.delay_between_hits = delay_between_hits
	hitbox.scale = size
	hitbox.attached_to_char = attached_to_character
	if duration > 0.0:
		hitbox.set_hitbox_lifetime(duration)
	return hitbox

func _ready():
	$GPUParticles2D.restart()

func set_hitbox_lifetime(time : float):
	$Timer.start(time)

func end_hitbox():
	queue_free()

func _on_body_entered(body):
	if body.has_method("hit") and body.team != team:
		if attached_to_char:
			body.hit(damage, attacker, attacker.global_position)
		else:
			body.hit(damage, attacker, global_position)

func _on_area_entered(area):
	if area.has_method("interact"):
		area.interact(attacker)

func _on_timer_timeout():
	end_hitbox()



