extends BaseSpecial
class_name SpecialMascot

const EGG = preload("res://scenes/Characters/Evolutions/Specials/EggProjectile.tscn")

@export var jump_power := 2500.0
@export var can_attack_cooldown := 0.25
@export var ability_cooldown := 0.6
@export var egg_hit_damage : int = 1   
@export var egg_hit_duration := 1.0
@export var egg_speed := 1400.0
@export var egg_hit_size := 5.0
@export var egg_hit_intensity := 1.0


func special():
	if not can_use_special:
		return
	can_use_special = false
	player.attacking = true
	player.knockback_velocity.y -= jump_power
	EggProjectile.spawn_egg_projectile(player, self)
	
	await get_tree().create_timer(can_attack_cooldown).timeout
	player.attacking = false
	
	await get_tree().create_timer(ability_cooldown).timeout
	can_use_special = true
