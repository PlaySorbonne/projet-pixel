extends CharacterBody2D
class_name Bullet

const BULLET_RES = preload("res://scenes/Characters/Evolutions/Specials/ManagerBullet.tscn")
const SPAWN_OFFSET = 50.0

var hit_damage := 3
var speed := 1800.0
var bullet_size := 1.0
var hit_intensity := 1.0
var direction : Vector2
var parent_player : PlayerCharacter 
var explosion_triggered := false

static func spawn_bullet(player_char : PlayerCharacter, special : SpecialManager):
	var bullet : Bullet = BULLET_RES.instantiate()
	bullet.hit_damage = special.bullet_hit_damage
	bullet.speed = special.bullet_speed
	bullet.bullet_size = special.bullet_size
	bullet.hit_intensity = special.bullet_hit_intensity
	if player_char.facing_right:
		bullet.direction = Vector2.RIGHT
		bullet.scale = Vector2.ONE * bullet.bullet_size
	else:
		bullet.direction = Vector2.LEFT
		bullet.scale = Vector2(-1.0, 1.0) * bullet.bullet_size
	bullet.position = player_char.global_position + (SPAWN_OFFSET * bullet.direction)
	bullet.parent_player = player_char
	GameInfos.world.add_child(bullet)

func _ready():
	velocity = direction * speed
	$AudioShoot.play_random_pitch()

func _physics_process(_delta):
	move_and_slide()

func _on_area_2d_body_entered(body):
	if explosion_triggered or body == parent_player:
		return
	explosion_triggered = true
	await get_tree().create_timer(0.05).timeout
	Hitbox.spawn_hitbox(parent_player, hit_damage, global_position, 0.1, 
	false, hit_intensity, Vector2(bullet_size, bullet_size))
	queue_free()
