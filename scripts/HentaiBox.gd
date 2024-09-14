extends RigidBody2D

signal game_won
signal hentai_hit

const BOUNDS = 3000

@export var anime_velocity := 1500.0
@export var anime_damage_multiplier := 1.0
@export var winning_by_weeb_touch := true

@onready var trail_effect := $TrailEffect
var team := -1
var knockback_velocity := Vector2.ZERO
var last_player_hit : PlayerCharacter = null
var last_hit_value := 0
var initial_position
var t := 0.0
var damaging := true

func _ready():
	await get_tree().create_timer(0.25).timeout
	initial_position = position
	connect("game_won", GameInfos.world.end_game)
	#physics_material_override.bounce = 1.0 # maybe put bounciness, etc as parameters

func _process(delta : float):
	t += delta
	if t > 1.0:
		t = 0.0
	if not (position.x < BOUNDS and position.x > -BOUNDS and position.y < BOUNDS and position.y > -BOUNDS):
		linear_velocity = Vector2.ZERO
		position = initial_position
	if linear_velocity.length() > 750:
		if not damaging:
			tween_trail_color(Color.RED)
		damaging = true
	else:
		if damaging:
			tween_trail_color(Color.DARK_CYAN)
		damaging = false

func tween_trail_color(new_color : Color):
	var tween := create_tween()
	tween.tween_property(trail_effect, "modulate", new_color, 0.15)

func get_hit_owner():
	return last_player_hit

func hit(damage : int, attacker : Node2D, hit_position : Vector2, hit_intensity := 1.0):
#	hit_position += Vector2(-30., 0.0)
	$Node/IconHit.global_position = hit_position
	$Node/IconSelf.global_position = global_position
	if attacker != null:
		var impulse_dir = global_position.direction_to(hit_position)
		if not (impulse_dir.length_squared() < 1.0):
			impulse_dir = Vector2.RIGHT
		apply_impulse( (impulse_dir + Vector2(0, -0.175)) * anime_velocity * hit_intensity)
	emit_signal("hentai_hit", damage)
	GameInfos.camera_utils.shake()
	last_player_hit = attacker
	last_hit_value = damage

func _on_area_2d_body_entered(body : Node2D):
	if not body.has_method("hit"):
		return
	var player_body : PlayerCharacter = body
	if winning_by_weeb_touch and player_body.current_evolution == PlayerCharacter.Evolutions.Weeb:
		emit_signal("game_won")
	elif damaging and last_player_hit != null and body != last_player_hit:
		player_body.hit(last_hit_value * anime_damage_multiplier, self, global_position)
