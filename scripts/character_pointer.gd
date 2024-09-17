extends Sprite2D
class_name CharacterPointer

const HEALTH_BAR_UNIT = preload(("res://scenes/Menus/GameUI/healthbar_unit.tscn"))
const HEALTH_BAR_POS_INIT = Vector2(-54, -50)
const HEALTH_PAR_POS_COEFF = Vector2(7, -31)

@export var shake_offset := Vector2.ZERO

@onready var default_pos = position
@onready var parent_character : Node2D = get_parent()
var total_hitpoints : int = 0
var current_hitpoints : int = 0
var healthbars : Array[HealthBarUnit] = [
	$HealthBars/HealthbarUnit,
	$HealthBars/HealthbarUnit2,
	$HealthBars/HealthbarUnit3
]

func _ready():
	pass
	# TODO
	# count total health and add how many progress bar you need, 
	# put them on good positions and fill em up real good uwu
# TODO
# also add function to take damage
# maybe something to shake the whole bar when taking damage
# and blink when total is 1 HP (and not weeb ? although weeb 
# constantly blinking might be fun

func get_current_unit() -> HealthBarUnit:
	return null

func set_max_hitpoints(hitpoints : int):
	for h : HealthBarUnit in healthbars:
		if h != null:
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
	print("set max hitpoints : " + str(hitpoints) + " -> " + str(num_health_bars))
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
		print("\tarray pos = " + str(array_pos))
		unit.position = HEALTH_BAR_POS_INIT + HEALTH_PAR_POS_COEFF * array_pos
		$HealthBars.add_child(unit)
	for unit : HealthBarUnit in healthbars:
		unit.add_unit()
		await get_tree().create_timer(0.175).timeout

func take_damage(damage : int, new_hitpoints : int):
	$HealthBars.shake(0.2, 15, 20*damage, damage)

func _process(_delta):
	global_position = parent_character.global_position + default_pos + shake_offset
