extends RigidBody2D

signal game_won

@export var anime_velocity := 4000.0
@export var anime_damage_multiplier := 1.0

var team := -1
var knockback_velocity := Vector2.ZERO
var last_player_hit : PlayerCharacter = null
var last_hit_value := 0

func _ready():
	pass
	#physics_material_override.bounce = 1.0 # maybe put bounciness, etc as parameters

func get_hit_owner():
	return last_player_hit

func hit(damage : int, attacker : Node2D = null):
	if attacker != null:
		apply_impulse( ((self.global_position - attacker.global_position
		).normalized() + Vector2(0, -0.1)) * 4000.0 )
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
		player_body.hit(last_hit_value * anime_damage_multiplier, self)
