extends "res://scripts/level_template.gd"

const XBOX_STICK_L = "[img]res://resources/images/interface/Xbox Series/Default/xbox_stick_l.png[/img]"
const XBOX_A = "[img]res://resources/images/interface/Xbox Series/Default/xbox_button_a_outline.png[/img]"
const XBOX_B = "[img]res://resources/images/interface/Xbox Series/Default/xbox_button_b_outline.png[/img]"
const XBOX_X = "[img]res://resources/images/interface/Xbox Series/Default/xbox_button_x_outline.png[/img]"

var STEPS_TEXTS = [
	"Bienvenue dans Decorporate ! Vous pouvez vous déplacer avec %s et sauter avec %s." % [XBOX_STICK_L, XBOX_A],
	"Vous pouvez utiliser votre attaque normale avec %s, et votre attaque spéciale avec %s." % [XBOX_X, XBOX_B],
	"Lorsque vous éliminez un adversaire, vous désévoluez. Atteignez l'évolution finale : le weeb pour continuer.",
	"Lorsque vous êtes weeb, vous pouvez attaquer la cassette d'anime pour tenter de vous en emparer.",
	"Une fois la cassette obtenue, vous fusionnez avec elle pour devenir un weeb exalté. Vous pouvez éliminer vos adversaires définitivement."
]

var current_step: int = 0
	
func init_step_1():
	pass
	
func init_step_2():
	pass

func init_step_3():
	pass
	
func init_step_4():
	pass

func show_step_text(step: int):
	var tutorial_text := $TutorialText
	var tween := create_tween()
	tween.tween_property(tutorial_text, "visible_ratio", 1.0, 2.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	show_step_text(current_step)
