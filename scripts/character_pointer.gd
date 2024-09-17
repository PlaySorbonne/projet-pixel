extends Sprite2D
class_name CharacterPointer

const HEALTH_BAR_UNIT = preload(("res://scenes/Menus/GameUI/healthbar_unit.tscn"))

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
	var num_health_bars := healthbars.size()
	var num_goal_health_bars := hitpoints / 5
	var diff_hitpoints := hitpoints - total_hitpoints
	if num_health_bars > num_goal_health_bars:
		for i : int in range(num_health_bars, num_goal_health_bars):
			var unit := HEALTH_BAR_UNIT.instantiate()
			var unit_health : int = min(5, diff_hitpoints)
			unit.set_health_value(unit_health)
			unit.position = Vector2()
			healthbars.append(unit)
			$HealthBars.add_child(unit)
			total_hitpoints += unit_health
			diff_hitpoints -= unit_health
	elif num_health_bars < num_goal_health_bars:
		for _i in range(num_goal_health_bars - num_health_bars):
			var unit : HealthBarUnit = healthbars.pop_back()
			unit.queue_free()
	total_hitpoints = hitpoints

func take_damage(damage : int, new_hitpoints : int):
	$HealthBars.shake(0.2, 15, 20*damage, damage)

func _process(_delta):
	global_position = parent_character.global_position + default_pos
