extends Sprite2D
class_name CharacterPointer

const HEALTH_BAR_UNIT = preload(("res://scenes/Menus/GameUI/healthbar_unit.tscn"))
const HEALTH_BAR_POS_INIT = Vector2(-54, -50)
const HEALTH_PAR_POS_COEFF = Vector2(7, -31)
const TIMER_TRANSPARENT := 3.5

static var current_z = 0

@export var shake_offset := Vector2.ZERO

@onready var default_pos = position
@onready var parent_character : Node2D = get_parent()
var total_hitpoints : int = 0
var current_hitpoints : int = 0
@onready var healthbars : Array[HealthBarUnit] = []

func _ready():
	$HealthBars.z_index = current_z * 5
	current_z += 1
	visible = false
	await get_tree().create_timer(0.1).timeout
	visible = true

func get_current_unit() -> HealthBarUnit:
	return null

func set_max_hitpoints(hitpoints : int):
	for h : HealthBarUnit in healthbars:
		h.queue_free()
	healthbars.clear()
	total_hitpoints = hitpoints
	current_hitpoints = hitpoints
	var num_health_bars := hitpoints / 5
	var last_unit_health := hitpoints % 5
	if last_unit_health > 0:
		num_health_bars += 1
	if last_unit_health == 0:
		last_unit_health = 5
	for i : int in range(num_health_bars):
		var unit := HEALTH_BAR_UNIT.instantiate()
		var unit_health : int
		if i == num_health_bars - 1:
			unit_health = last_unit_health
		else:
			unit_health = 5
		unit.set_health_value(unit_health)
		healthbars.append(unit)
		var array_pos := healthbars.size()-1
		unit.position = HEALTH_BAR_POS_INIT + HEALTH_PAR_POS_COEFF * array_pos
		$HealthBars.add_child(unit)
	var delay := 0
	for unit : HealthBarUnit in healthbars:
		unit.add_unit(delay)
		await get_tree().create_timer(0.175).timeout
		delay += 5
	show_health_bars()

func take_damage(damage : int, new_hitpoints : int):
	var d := current_hitpoints - new_hitpoints
	var delay := 0
	var healthbar_counter = 1
	while d > 0:
		var current_health_bar := healthbars[healthbars.size() - healthbar_counter]
		var unit_dmg : int = min(d, current_health_bar.health)
		d -= unit_dmg
		current_health_bar.damage(unit_dmg, delay)
		if d > 0:
			healthbar_counter += 1
			if healthbar_counter > len(healthbars):
				d = 0
		delay += unit_dmg
	current_hitpoints = new_hitpoints
	$HealthBars.shake(0.2, 15, 20*damage, damage)
	show_health_bars()

func _process(_delta):
	global_position = parent_character.global_position + default_pos + shake_offset

func show_health_bars():
	tween_color(Color.WHITE)
	$Timer.start(TIMER_TRANSPARENT)

func _on_timer_timeout():
	tween_color(Color(1.0, 1.0, 1.0, 0.4))

func tween_color(new_color : Color):
	var tween := create_tween()
	tween.tween_property($HealthBars, "modulate", new_color, 0.25)
