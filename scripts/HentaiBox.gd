extends RigidBody2D

signal game_won
signal hentai_hit

const BOUNDS = 3000
const LIMIT_SPEED_DAMAGE_DOWN = pow(300, 2.0)
const DAMAGING_TIME_MIN = 0.25

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
var damaging_timer := 0.0

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
	if damaging_timer > 0.0:
		damaging_timer -= delta
	elif damaging and linear_velocity.length_squared() < LIMIT_SPEED_DAMAGE_DOWN:
		tween_disk_color(Color.DARK_CYAN, 0.45, 0.0, 1.0, 1.0)
		damaging = false

func tween_disk_color(new_color : Color, time : float, chaos : float, div_green : float, div_blue : float):
	var tween := create_tween().set_parallel()
	tween.tween_property(trail_effect, "modulate", new_color, time)
	tween.tween_property($Sprite2D, "material:shader_parameter/chaos", chaos, time)
	tween.tween_property($Sprite2D, "material:shader_parameter/divider_green", div_green, time)
	tween.tween_property($Sprite2D, "material:shader_parameter/divider_blue", div_blue, time)

func get_hit_owner():
	return last_player_hit

func hit(damage : int, attacker : Node2D, hit_position : Vector2, hit_intensity := 1.0):
	if attacker != null:
		var impulse_dir : Vector2 = (global_position-hit_position).normalized()
		apply_impulse( (impulse_dir + Vector2(0, -0.175)) * anime_velocity * hit_intensity  )
	emit_signal("hentai_hit", damage)
	GameInfos.camera_utils.shake()
	last_player_hit = attacker
	last_hit_value = damage
	tween_disk_color(Color.RED, 0.1, 60.0, 5.0, 1.75)
	damaging = true
	damaging_timer = DAMAGING_TIME_MIN

func _on_area_2d_body_entered(body : Node2D):
	if not body.has_method("hit"):
		return
	var player_body : PlayerCharacter = body
	if winning_by_weeb_touch and player_body.current_evolution == PlayerCharacter.Evolutions.Weeb:
		emit_signal("game_won")
	elif damaging and last_player_hit != null and body != last_player_hit:
		player_body.hit(last_hit_value * anime_damage_multiplier, self, global_position)
