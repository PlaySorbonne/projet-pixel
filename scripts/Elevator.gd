extends Area2D

@export var other_teleporters: Array
@export var teleport_delay: float = 1.0  

var can_teleport: bool = true

func _ready():
	
	connect("body_entered", Callable(self, "_on_body_entered"))


func _process(delta):
	pass


func _on_body_entered(body):
	if can_teleport:
		can_teleport = false
		
		# Selection random
		randomize() # pour tjrs avoir des tp aléatoires
		var target_index = randi() % other_teleporters.size()
		var target_teleporter = get_node(other_teleporters[target_index])
		body.global_position = target_teleporter.global_position
		
		target_teleporter.disable_teleport() #empeche de perma tp
		$Timer.start(teleport_delay)

func disable_teleport():
	can_teleport = false
	$Timer.start(teleport_delay + 2)

func _on_timer_timeout():
	can_teleport = true
