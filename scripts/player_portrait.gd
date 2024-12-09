extends Control
class_name PlayerPortrait

const PLAYER_PORTRAITS = [
	preload("res://resources/images/characters/CEO/CEO_portrait.png"),
	preload("res://resources/images/characters/fox/fox_portrait.png"),
	preload("res://resources/images/characters/Sheep/mouton_portrait.png"),
	preload("res://resources/images/characters/chicken/chicken_portrait.png"),
	preload("res://resources/images/characters/weeb/weeb_portrait.png")
]

var player_number := 0
var current_evolution := -1
var init_portrait := false
var velocity := Vector2.ZERO
var eliminated := false
var current_lives := -1

func _ready():
	set_process(false)
	GameInfos.player_portraits[player_number] = self
	if GameInfos.lives_limit > 0:
		current_lives = GameInfos.lives_limit
		$Holder/LabelLives.text = str(current_lives)
		$Holder/LabelLives.visible = true

func _process(delta):
	$Holder.position += delta * velocity

func initialize_portrait(player_num : int):
	player_number = player_num
	GameInfos.player_portaits[player_number] = self
	var player_color : Color = GameInfos.players_data[player_num]["color"]
	$Holder/TextureBackground.modulate = player_color
	connect_player_object()
	update_health()
	update_evolution()
	var player : PlayerCharacter = GameInfos.players[player_num]
	$Holder/LabelName.text = GameInfos.players_data[player_num]["name"]
	if not player.is_player_controlled:
		$Holder/TextureRobot.visible = true
		#$Holder/TextureRobot.modulate = player_color

func eliminate(vel : Vector2):
	if eliminated:
		return
	velocity = Vector2(vel.x, max(-25.0, vel.y))
	eliminated = true
	set_process(true)
	await get_tree().create_timer(5.0).timeout
	set_process(false)

func connect_player_object():
	var player : PlayerCharacter = GameInfos.players[player_number]
	player.fighter_hit.connect(update_health)
	player.player_spawned.connect(update_health)
	player.player_evolved.connect(update_evolution)
	if GameInfos.lives_limit > 0:
		player.fighter_died.connect(update_lives)

func update_lives(_player : PlayerCharacter) -> void:
	current_lives -= 1
	$Holder/LabelLives.text = str(current_lives)
	$AnimationPlayer.play("anim_death")

func update_health(_damage := 0, _hitpoints := 0):
	var player : PlayerCharacter = GameInfos.players[player_number]
	$Holder/LabelHealth.text = str(max(0, player.hitpoints)
	) + "/" + str(player.max_hitpoints)

func update_evolution(_evolution = null):
	connect_player_object()
	var new_evolution = GameInfos.players[player_number].current_evolution
	if new_evolution == current_evolution:
		return
	if init_portrait:
		$Shaker.shake(0.35, 25, 20)
		$AnimationPlayer.play("evolve")
		tween_labels_color()
	else:
		init_portrait = true
	current_evolution = new_evolution
	var new_texture = PLAYER_PORTRAITS[new_evolution]
	var new_name : String = PlayerCharacter.Evolutions.keys()[new_evolution]
	$Holder/TexturePortrait.texture = new_texture
	$Holder/TexturePortraitBackground.texture = new_texture
	$Holder/LabelEvolution.text = new_name
	update_health()

func tween_labels_color():
	var labels : Array[Control] = [$Holder/LabelName, $Holder/LabelHealth, $Holder/LabelEvolution]
	var new_color : Color = Color.GOLD
	var anim_time := 0.25
	for i in range(2):
		var t : Tween = get_tree().create_tween()
		t.tween_property(labels[0], "modulate", new_color, anim_time)
		t.parallel().tween_property(labels[1], "modulate", new_color, anim_time)
		t.parallel().tween_property(labels[2], "modulate", new_color, anim_time)
		await get_tree().create_timer(0.1+anim_time).timeout
		new_color = Color.WHITE
		anim_time = 0.5
