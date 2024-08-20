extends RigidBody2D

signal game_won

const BOUNDS = 3000

@export var anime_velocity := 2000.0
@export var anime_damage_multiplier := 1.0

var team := -1
var knockback_velocity := Vector2.ZERO
var last_player_hit : PlayerCharacter = null
var last_hit_value := 0
var initial_position
var t := 0.0

func _ready():
	await get_tree().create_timer(0.25).timeout
	initial_position = position
	#physics_material_override.bounce = 1.0 # maybe put bounciness, etc as parameters

func _process(delta):
	t += delta
	if t > 1.0:
		t = 0.0
	if not (position.x < BOUNDS and position.x > -BOUNDS and position.y < BOUNDS and position.y > -BOUNDS):
		linear_velocity = Vector2.ZERO
		position = initial_position

func get_hit_owner():
	return last_player_hit

func hit(damage : int, attacker : Node2D, hit_position : Vector2):
	if attacker != null:
		var impulse_dir = (self.global_position - hit_position).normalized()
		if not (impulse_dir.length_squared() < 1.0):
			impulse_dir = Vector2.RIGHT
		apply_impulse( (impulse_dir + Vector2(0, -0.1)) * anime_velocity )
	GameInfos.camera_utils.shake()
	last_player_hit = attacker
	last_hit_value = damage

func _on_area_2d_body_entered(body):
	if not body.has_method("hit"):
		return
	var player_body : PlayerCharacter = body
	if player_body.current_evolution == PlayerCharacter.Evolutions.Weeb:
		emit_signal("game_won")
	elif linear_velocity.length() > 750 and last_player_hit != null and body != last_player_hit:
		player_body.hit(last_hit_value * anime_damage_multiplier, self, global_position)
