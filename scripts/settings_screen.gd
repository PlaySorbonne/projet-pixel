extends Control
class_name SettingsScreen

signal ButtonBackPressed

enum Languages {English, Francais}

const DEFAULT_GAMEPLAY_FILE = "res://default_gameplay_stats.txt"
const GAMEPLAY_FILE_NAME = "OOgameplay_stats.txt"
const SETTINGS_FILE_NAME = "user://ascend_settings.txt"
const LANGUAGE_KEYS = [
	"en",
	"fr"
]

static var default_gameplay_file := OS.get_executable_path().get_base_dir() + "/" + GAMEPLAY_FILE_NAME
static var default_gameplay_data : Dictionary = {}
static var user_settings : Dictionary = {
	"fullscreen" : true,
	"music_volume" : 0.75,
	"sfx_volume" : 0.75,
	"language" : Languages.Francais,
	"stats" : default_gameplay_file
}

static func apply_settings():
	update_language()
	update_fullscreen()
	update_audio()
	update_stats_file()

func _ready():
	$Options/ButtonFullscreen.button_pressed = user_settings["fullscreen"]
	$Options/LanguageButton.selected = user_settings["language"]
	print("user_settings = " + str(user_settings))
	print("user_settings['stats'] = " + str(user_settings["stats"]))

func _on_button_back_pressed():
	$ButtonBack.release_focus()
	emit_signal("ButtonBackPressed")

static func save_settings_data():
	var save_file := FileAccess.open(SETTINGS_FILE_NAME, FileAccess.WRITE)
	save_file.store_line(JSON.stringify(user_settings))
	save_file.close()

static func load_settings_data(reapply_settings := true):
	if not FileAccess.file_exists(SETTINGS_FILE_NAME):
		# no settings file exist on this computer
		return 
	var save_file := FileAccess.open(SETTINGS_FILE_NAME, FileAccess.READ)
	var json_string := save_file.get_line()
	var json := JSON.new()
	var parse_result := json.parse(json_string)
	if not parse_result == OK:
		print("JSON parse error in loading settings file")
		return
	user_settings = json.get_data()
	save_file.close()
	if reapply_settings:
		apply_settings()
	else:
		update_language()

static func update_fullscreen():
	if user_settings["fullscreen"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

static func update_audio():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), 
		linear_to_db(user_settings["music_volume"]))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx"), 
		linear_to_db(user_settings["sfx_volume"]))

static func update_language():
	TranslationServer.set_locale(LANGUAGE_KEYS[user_settings["language"]])

static func update_stats_file():
	if user_settings.has("stats"):
		user_settings['stats']
	else:
		user_settings['stats'] = default_gameplay_file
	var user_gameplay_file : String = user_settings['stats']
	if not FileAccess.file_exists(user_gameplay_file):
		# write default stats file cuz there isn't one duh
		var default_stats_file := FileAccess.open(DEFAULT_GAMEPLAY_FILE, FileAccess.READ)
		var new_gameplay_file := FileAccess.open(user_gameplay_file, FileAccess.WRITE)
		new_gameplay_file.store_string(default_stats_file.get_as_text())
		new_gameplay_file.close()
		default_stats_file.close()
	var game_stats := FileAccess.open(user_gameplay_file, FileAccess.READ)

func _on_button_fullscreen_toggled(toggled_on : bool):
	user_settings["fullscreen"] = toggled_on
	update_fullscreen()
	save_settings_data()

func _on_music_slider_value_changed(value : float):
	user_settings["music_volume"] = value
	update_audio()
	save_settings_data()

func _on_sf_xslider_value_changed(value : float):
	user_settings["sfx_volume"] = value
	update_audio()
	save_settings_data()

func _on_language_button_item_selected(index : int):
	user_settings["language"] = index
	update_language()
	save_settings_data()

func _on_button_stats_pressed():
	$FileDialog.popup_centered_ratio(0.8)

func _on_button_stats_reset_pressed():
	pass # Replace with function body.
