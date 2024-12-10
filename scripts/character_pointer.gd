extends Sprite2D
class_name CharacterPointer

signal healthbars_displayed

const HEALTH_BAR_UNIT := preload(("res://scenes/Menus/GameUI/healthbar_unit.tscn"))
const HEALTH_BAR_POS_INIT := Vector2(-54, -50)
const HEALTH_PAR_POS_COEFF := Vector2(7, -31)
const TIMER_TRANSPARENT := 3.5
const TEXTURE_REF := preload("res://resources/images/characters/character_pointer.png")
const DEFAULT_HEALTH_COLOR := Color(0.812, 0.0, 0.0)
const DELAY_BETWEEN_HP_CHANGE := 0.2

static var current_z = 0

@export var shake_offset := Vector2.ZERO
@export var has_name := true:
	set(value):
		has_name = value
		$HealthBars/LabelName.visible = has_name
		$StarRect.visible = has_name
@export var has_pointer := true:
	set(value):
		has_pointer = value
		if has_pointer:
			texture = TEXTURE_REF
		else:
			texture = null
@export var always_show_healthbars := false

@onready var default_pos = position
@onready var parent_character : Node2D = get_parent()
var player_id := -1:
	set(value):
		player_id = value
		if player_id >= 0:
			$TimerCheckWinner.start()
var total_hitpoints : int = 0
var target_hitpoints : int = 0
var current_hitpoints : int = 0
var healthbars : Array[HealthBarUnit] = []
var healthbar_anim_in_progress := false
var default_healthbar_color : Color = DEFAULT_HEALTH_COLOR

func _ready() -> void:
	$HealthBars.z_index = current_z * 5
	current_z += 1
	visible = false
	has_name = has_name
	has_pointer = has_pointer
	await get_tree().create_timer(0.15).timeout
	$StarRect.modulate = self_modulate
	visible = true

var time_since_change_hp := 0.0
func _process(delta : float) -> void:
	global_position = parent_character.global_position + default_pos + shake_offset
	time_since_change_hp += delta
	
	if time_since_change_hp > DELAY_BETWEEN_HP_CHANGE and current_hitpoints != target_hitpoints:
		time_since_change_hp = 0.0
		if current_hitpoints > target_hitpoints and len(healthbars) > 0:
			var current_health_bar : HealthBarUnit = healthbars[healthbars.size()-1]
			current_hitpoints -= 1
			if current_health_bar.damage(1, 0):
				healthbars.pop_back()
		else:
			print("huh. well that shouldn't be here. helthbars = " + str(healthbars))

func set_healthbars_color(new_color : Color):
	default_healthbar_color = new_color
	for h : HealthBarUnit in healthbars:
		h.default_health_color = default_healthbar_color

func set_star(new_vis : bool):
	var tween := create_tween().set_parallel()
	var new_mod : Color
	var new_bg : Color
	if new_vis:
		new_mod = Color.WHITE
		new_bg = Color.BLACK
	else:
		new_mod = Color.BLACK
		new_bg = Color.TRANSPARENT
	tween.tween_property($StarRect, "self_modulate", new_mod, 0.15)
	tween.tween_property($StarRect/StarRect2, "self_modulate", new_bg, 0.2)

func get_current_unit() -> HealthBarUnit:
	return null

func set_zero_hitpoints():
	for h : HealthBarUnit in healthbars:
		h.queue_free()
	var unit := HEALTH_BAR_UNIT.instantiate()
	unit.set_health_value(0)
	$HealthBars.add_child(unit)
	unit.position = HEALTH_BAR_POS_INIT
	unit.default_health_color = default_healthbar_color
	healthbars = [unit]
	unit.add_unit_no_anim()

var is_winner := false
func set_winner(new_winner : bool) -> void:
	if is_winner == new_winner:
		return
	is_winner = new_winner
	var f_val : Vector2
	if is_winner:
		f_val = Vector2(1.5, 1.5)
	else:
		f_val = Vector2.ZERO
	var t := create_tween().set_trans(Tween.TRANS_ELASTIC)
	t.tween_property($HealthBars/TextureTrophy, "scale", f_val, 0.75)

func set_max_hitpoints(hitpoints : int, with_anim := true):
	if hitpoints == 0:
		set_zero_hitpoints()
		return
	healthbar_anim_in_progress = true
	for h : HealthBarUnit in healthbars:
		h.queue_free()
	healthbars.clear()
	total_hitpoints = hitpoints
	target_hitpoints = hitpoints
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
		unit.unit_removed.connect(update_nodes_position)
		if i == num_health_bars - 1:
			unit_health = last_unit_health
		else:
			unit_health = 5
		unit.set_health_value(unit_health)
		healthbars.append(unit)
		var array_pos := healthbars.size()-1
		unit.position = HEALTH_BAR_POS_INIT + HEALTH_PAR_POS_COEFF * array_pos
		$HealthBars.add_child(unit)
		unit.default_health_color = default_healthbar_color
	update_nodes_position()
	var tween := create_tween()
	tween.tween_property($StarRect, "scale", Vector2.ONE, 0.4)
	var delay := 0
	for unit : HealthBarUnit in healthbars:
		if with_anim:
			unit.add_unit(delay)
			await get_tree().create_timer(0.175).timeout
			delay += 5
		else:
			unit.add_unit_no_anim()
	show_health_bars()
	healthbar_anim_in_progress = false
	emit_signal("healthbars_displayed")

func update_nodes_position() -> void:
	var new_name_pos := Vector2(
		-160.0 + 7.5 * healthbars.size(),
		HEALTH_BAR_POS_INIT.y + HEALTH_PAR_POS_COEFF.y * healthbars.size() - 20.0
	)
	var t := create_tween().set_ease(Tween.EASE_OUT).set_parallel()
	t.tween_property($HealthBars/LabelName, "position", new_name_pos, 0.1)
	t.tween_property($HealthBars/TextureTrophy, "position", new_name_pos + Vector2(
										126, -60), 0.1)
	t.tween_property($StarRect, "position", Vector2(
		-95.0,
		new_name_pos.y / 2.0 - 5.0
	), 0.1)

func set_character_name(new_name : String):
	$HealthBars/LabelName.text = new_name

func take_damage(damage : int, new_hitpoints : int):
	if healthbar_anim_in_progress:
		await self.healthbars_displayed
	target_hitpoints = max(0, target_hitpoints - damage)
	
	var current_health_bar : HealthBarUnit
	var healthbar_counter = 1
	var tmp_dmg := damage
	while tmp_dmg > 0:
		current_health_bar = healthbars[healthbars.size() - healthbar_counter]
		var unit_dmg : int = min(tmp_dmg, current_health_bar.health)
		tmp_dmg -= unit_dmg
		current_health_bar.setup_damage(unit_dmg)
		if tmp_dmg > 0:
			healthbar_counter += 1
			if healthbar_counter > len(healthbars):
				tmp_dmg = 0
	
	$HealthBars.shake(0.2, 15, 20*damage, damage)
	show_health_bars()

func show_health_bars():
	tween_color(Color.WHITE)
	if not always_show_healthbars:
		$Timer.start(TIMER_TRANSPARENT)

func _on_timer_timeout():
	pass
	#tween_color(Color(1.0, 1.0, 1.0, 0.4))

func tween_color(new_color : Color):
	var tween := create_tween()
	tween.tween_property($HealthBars, "modulate", new_color, 0.25)

func _on_timer_check_winner_timeout() -> void:
	set_winner(player_id in GameInfos.tmp_winners)
