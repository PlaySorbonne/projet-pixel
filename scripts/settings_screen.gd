extends Control
class_name SettingsScreen

signal ButtonBackPressed

enum Languages {English, Francais}

const SETTINGS_FILE_NAME = "user://ascend_settings.txt"
const LANGUAGE_KEYS = [
	"en",
	"fr"
]

static var user_settings : Dictionary = {
	"fullscreen" : true,
	"music_volume" : 0.75,
	"sfx_volume" : 0.75,
	"language" : Languages.Francais
}

static func apply_settings():
	update_language()
	update_fullscreen()
	update_audio()

func _ready():
	$Options/LabelFullscreen/ButtonFullscreen.button_pressed = user_settings["fullscreen"]

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
	print("now translate to " + str(LANGUAGE_KEYS[user_settings["language"]]))
	TranslationServer.set_locale("fr")

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
