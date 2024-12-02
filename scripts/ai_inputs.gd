extends Node
class_name AI_Inputs

enum Behaviors {PutDistance, AttackNearest, AttackLowestHealth}

const UPDATE_TIME_LIMIT := 0.7
const MIN_TIME_BETWEEN_BEHAVIORS := 3.0
const MIN_TIME_BETWEEN_SPECIALS := 2.0
const MIN_TIME_BETWEEN_ATTACKS := 0.5

var time_since_behavior_change := 0.0
var time_since_special := 0.0
var time_since_attack := 0.0
var update_time := 0.0
var reaction_time := 0.1

var enemy_ids : Array[int] = []
var enemies : Array[PlayerCharacter] = []
var enemy_distances : Array[float] = []
var enemy_directions : Array[Vector2] = []
var enemy_hitpoints : Array[int] = []
var enemy_position_differences : Array[Vector2] = []
#var enemy_velocities : Array[Vector2] = []
var current_behavior : Behaviors = Behaviors.AttackNearest

@onready var player : PlayerCharacter = self.get_parent()

func _ready() -> void:
	for p_id : int in GameInfos.players.keys():
		if p_id != player.player_ID:
			enemy_ids.append(p_id)

func player_special() -> void:
	player.special()
	time_since_special = 0.0

func player_attack() -> void:
	player.attack()
	time_since_attack = 0.0

func set_behavior() -> void:
	time_since_behavior_change = 0.0
	current_behavior = Behaviors.values().pick_random()

func update_enemies(delta : float, force_update := false) -> void:
	update_time -= delta
	time_since_behavior_change += delta
	if time_since_behavior_change >= MIN_TIME_BETWEEN_BEHAVIORS:
		set_behavior()
	if update_time > 0.0 and not force_update:
		return
	update_time = UPDATE_TIME_LIMIT
	enemies = []
	enemy_distances = []
	enemy_directions = []
	enemy_hitpoints = []
	enemy_position_differences = []
	var location := player.global_position
	for id : int in enemy_ids:
		var current_enemy : PlayerCharacter = GameInfos.players[id]
		var enemy_location : Vector2 = current_enemy.global_position
		enemies.append(GameInfos.players[id])
		enemy_distances.append(location.distance_squared_to(enemy_location))
		enemy_directions.append(location.direction_to(enemy_location))
		enemy_hitpoints.append(current_enemy.hitpoints)
		enemy_position_differences.append(location - enemy_location)

func _process(_delta: float) -> void:
	pass
	# actions:
		# move (left/right/drop down)
		# jump/stop_jump
		# use special
		# attack
	# considerations:
		# ascended weeb
		# other players
		# cassette
		# platforms
		# semi-solid platforms
	
	# COMMANDS:
		# player.right_pressed
		# player.left_pressed
		# player.up_pressed
		# player.down_pressed
		
		# player.jump()
		# player.stop_jump()
		
		# player.attack()
		# player.special()
