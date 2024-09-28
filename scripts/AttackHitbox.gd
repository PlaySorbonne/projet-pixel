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
var compute_hits := true
var draw_particles := true
var particles_finished := false
var eliminate_targets := false
var custom_audio : AudioStream = null

static func spawn_hitbox(parent : FighterCharacter, hit_damage : int, hitbox_location : Vector2,
duration : float, attached_to_character := true, hit_intensity := 1.0, size := Vector2.ONE,
can_multi_hit := false, delay_between_hits := 0.4) -> Hitbox:
	var hitbox : Hitbox = HITBOX_SCENE.instantiate()
	hitbox.team = parent.team
	hitbox.damage = hit_damage
	hitbox.attacker = parent
	hitbox.intensity = hit_intensity
	hitbox.set_audio_pitch_multiplier(1.15 - (float(hit_damage) / 10.0))
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
	if draw_particles:
		$GPUParticles2D.restart()
		if custom_audio != null:
			$AudioAttack.stream = custom_audio
		$AudioAttack.play_random_pitch()

func set_eliminate(new_eliminate := true) -> Hitbox:
	eliminate_targets = new_eliminate
	if new_eliminate:
		$GPUParticles2D.self_modulate = Color.DARK_RED
	else:
		$GPUParticles2D.self_modulate = Color.WHITE
	return self

func set_audio(new_audio : AudioStream):
	custom_audio = new_audio

func set_audio_pitch_multiplier(val : float):
	$AudioAttack.pitch_multiplier = val

func no_particles():
	particles_finished = true
	draw_particles = false
	$GPUParticles2D.visible = false

func set_hitbox_lifetime(time : float):
	$Timer.start(time)

func end_hitbox():
	compute_hits = false
	if particles_finished:
		queue_free()

func _on_body_entered(body : Node2D):
	if not compute_hits:
		return
	if eliminate_targets and body.has_method("eliminate") and body.team != team:
		if attached_to_char:
			body.eliminate(attacker, attacker.global_position)
		else:
			body.eliminate(attacker, global_position)
	elif body.has_method("hit") and body.team != team:
		if attached_to_char:
			body.hit(damage, attacker, attacker.global_position, intensity)
			#print("attacker_position : " + str(attacker.global_position) + " // body_position : " + str(body.global_position))
		else:
			body.hit(damage, attacker, global_position, intensity)
			#print("hitbox_position : " + str(global_position) + " // body_position : " + str(body.global_position))

func _on_area_entered(area):
	if area.has_method("interact"):
		area.interact(attacker)

func _on_timer_timeout():
	end_hitbox()

func _on_gpu_particles_2d_finished():
	particles_finished = true
	if not compute_hits:
		queue_free()
