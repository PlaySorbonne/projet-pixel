extends Level

const MENU_PATH = "res://scenes/Menus/MenuPersistent.tscn"

const XBOX_STICK_L = "[img]res://resources/images/interface/Xbox Series/Default/xbox_stick_l.png[/img]"
const XBOX_A = "[img]res://resources/images/interface/Xbox Series/Default/xbox_button_a_outline.png[/img]"
const XBOX_B = "[img]res://resources/images/interface/Xbox Series/Default/xbox_button_b_outline.png[/img]"
const XBOX_X = "[img]res://resources/images/interface/Xbox Series/Default/xbox_button_x_outline.png[/img]"

# TODO: localize text
var STEPS_TEXTS = [
	"Bienvenue dans Decorporate ! Vous pouvez vous déplacer avec %s et sauter avec %s." % [XBOX_STICK_L, XBOX_A],
	"Vous pouvez utiliser votre attaque normale avec %s, et votre attaque spéciale avec %s." % [XBOX_X, XBOX_B],
	"Lorsque vous éliminez un adversaire, vous désévoluez. Atteignez l'évolution finale : le weeb pour continuer.",
	"Lorsque vous êtes weeb, vous pouvez attaquer la cassette d'anime pour tenter de vous en emparer.",
	"Une fois la cassette obtenue, vous fusionnez avec elle pour devenir un weeb exalté. Vous pouvez éliminer vos adversaires définitivement."
]

var current_step: int = 0
var player_id: int = 0
var ennemy_id: int = 0


var actions_done = {
	"jump": false,
	"move": false,
	"attack": false,
	"special_attack": false,
	"weeb": false,
	"ultimate_weeb": false,
	"win": false
}
	
func init_step_2():
	GameInfos.players[ennemy_id].spawn($EnnemySpawnLocation.position)

func init_step_3():
	GameInfos.anime_box.toggle_cassette(true)
	GameInfos.anime_box.force_position($AnimeSpawnLocation.position)
	
func init_step_4():
	pass

func show_step_text(step: int):
	var tutorial_text := $TutorialText
	tutorial_text.text = STEPS_TEXTS[step]
	tutorial_text.visible_ratio = 0.0
	var tween := create_tween()
	tween.tween_property(tutorial_text, "visible_ratio", 1.1, 2.0) # 1.1 instead of 1.0 to get the last character (idk why)

func _ready() -> void:
	GameInfos.anime_box.toggle_cassette(false)
	for p: PlayerCharacter in GameInfos.players.values():
		if p.current_evolution == PlayerCharacter.Evolutions.CEO:
			player_id = p.player_ID
		elif p.current_evolution == PlayerCharacter.Evolutions.Mascot:
			ennemy_id = p.player_ID
	show_step_text(current_step)
	await get_tree().process_frame
	connect_players()

func connect_players():
	GameInfos.world.add_child(GameInfos.players[ennemy_id])
	GameInfos.world.add_child(GameInfos.players[player_id])
	
	GameInfos.players[player_id].spawn($SpawnLocation1.position)
	GameInfos.world.connect("game_finished", _on_game_finished)
	
func _process(delta: float) -> void:
	if actions_done["jump"] and actions_done["move"] and current_step == 0:
		current_step = 1
		show_step_text(current_step)
	if actions_done["attack"] and actions_done["special_attack"] and current_step == 1:
		init_step_2()
		current_step = 2
		show_step_text(current_step)
	if GameInfos.players[player_id].current_evolution == PlayerCharacter.Evolutions.Weeb and current_step == 2:
		init_step_3()
		current_step = 3
		show_step_text(current_step)
	if GameInfos.players[player_id] is WeebCharacter and GameInfos.players[player_id].ascended and current_step == 3:
		current_step = 4
		show_step_text(current_step)

		
func _input(event: InputEvent) -> void:
	GameInfos.players[player_id].control_device = event.device
	if event is InputEventKey:
		GameInfos.players[player_id].control_type = 0
	elif (event is InputEventJoypadButton) or (event is InputEventJoypadMotion):
		GameInfos.players[player_id].control_type = 1
	if event.is_action_pressed("jump") and not actions_done["jump"]:
		actions_done["jump"] = true
	if (event.is_action_pressed("right") or event.is_action_pressed("left")):
		actions_done["move"] = true
	if event.is_action_pressed("attack") and (not actions_done["attack"]) and current_step == 1:
		actions_done["attack"] = true
	if event.is_action_pressed("special") and (not actions_done["special_attack"]) and current_step == 1:
		actions_done["special_attack"] = true
		
func _on_game_finished() -> void:
	if get_tree() != null:
		await get_tree().create_timer(1.0).tiemout
		get_tree().change_scene_to_file(MENU_PATH)
