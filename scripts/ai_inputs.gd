extends Node
class_name AI_Inputs

const UPDATE_TIME_LIMIT := 1.0

var update_time := 0.0
var reaction_time := 0.1
var enemy_ids : Array[int] = []
var enemies : Array[PlayerCharacter] = []
var enemy_distances : Array[float] = []
var enemy_directions : Array[Vector2] = []

@onready var player : PlayerCharacter = self.get_parent()


func _ready() -> void:
	for p_id : int in GameInfos.players.keys():
		if p_id != player.player_ID:
			enemy_ids.append(p_id)

func update_enemies(delta : float, force_update := false) -> void:
	update_time -= delta
	if update_time > 0.0 and not force_update:
		return
	update_time = UPDATE_TIME_LIMIT
	enemies = []
	enemy_distances = []
	enemy_directions = []
	var location := player.global_position
	for id : int in enemy_ids:
		var enemy_location : Vector2 = GameInfos.players[id].global_position
		enemies.append(GameInfos.players[id])
		enemy_distances.append(location.distance_squared_to(enemy_location))
		enemy_directions.append(location.direction_to(enemy_location))

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
