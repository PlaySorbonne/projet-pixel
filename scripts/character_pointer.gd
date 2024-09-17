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
var healthbars : Array[HealthBarUnit] = []

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
	print("new_hitpoints = " + str(hitpoints))
	var num_health_bars := healthbars.size()
	var num_goal_health_bars := hitpoints / 5
	var diff_hitpoints := hitpoints - total_hitpoints
	print("\tdiff_hitpoints = " + str(diff_hitpoints))
	if num_health_bars < num_goal_health_bars:
		for i : int in range(num_health_bars, num_goal_health_bars):
			var unit := HEALTH_BAR_UNIT.instantiate()
			var unit_health : int = min(5, diff_hitpoints)
			unit.set_health_value(unit_health)
			healthbars.append(unit)
			var array_pos := healthbars.size()-1
			unit.position = HEALTH_BAR_POS_INIT + HEALTH_PAR_POS_COEFF * array_pos
			print("\tarray_pos = " + str(array_pos) + " ; pos = "+str(unit.position))
			$HealthBars.add_child(unit)
			unit.add_unit()
			total_hitpoints += unit_health
			diff_hitpoints -= unit_health
	elif num_health_bars > num_goal_health_bars:
		for _i in range(num_goal_health_bars - num_health_bars):
			var unit : HealthBarUnit = healthbars.pop_back()
			unit.remove_unit()
		var unit_health : int # TODO : set last bar health
	total_hitpoints = hitpoints

func take_damage(damage : int, new_hitpoints : int):
	$HealthBars.shake(0.2, 15, 20*damage, damage)

func _process(_delta):
	global_position = parent_character.global_position + default_pos + shake_offset
