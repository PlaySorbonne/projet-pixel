extends Control
class_name EndScreen

var is_end_game := false

func _ready() -> void:
	print("WORLD -> CANVASLAYER -> END_SCREEN: REMEMBER TO HIDE END_SCREEN AND SHOW SCREEN_TRANSITION")

func init_end_screen() -> void:
	is_end_game = true
