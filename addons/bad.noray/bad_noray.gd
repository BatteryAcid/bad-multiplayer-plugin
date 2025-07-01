@tool
extends EditorPlugin

const ROOT = "res://addons/bad.noray"

var BAD_NORAY_PLUGIN_SETTING = {
	"name": "bad.multiplayer/networks/noray",
	"value": false,
	"type": TYPE_BOOL
}

const AUTOLOADS = [
	{
		"name": "BADAsync",
		"path": ROOT + "/autoloads/bad_async.gd"
	}
]

func _enter_tree() -> void:

	add_setting(BAD_NORAY_PLUGIN_SETTING)
	
	if EditorInterface.is_plugin_enabled("netfox.noray"):
		print("Netfox's Noray is enabled, enabling bad.noray network!")
		ProjectSettings.set_setting(BAD_NORAY_PLUGIN_SETTING.name, true)

		for autoload in AUTOLOADS:
			add_autoload_singleton(autoload.name, autoload.path)
	else:
		print("Netfox's Noray is disabled, turning off bad.noray network...")
		ProjectSettings.set_setting(BAD_NORAY_PLUGIN_SETTING.name, false)

func _exit_tree() -> void:
	for autoload in AUTOLOADS:
		remove_autoload_singleton(autoload.name)

func add_setting(setting: Dictionary):
	if ProjectSettings.has_setting(setting.name):
		return

	# print("Adding setting %s with value: %s " % [setting.name, setting.value])
	ProjectSettings.set_setting(setting.name, setting.value)
	ProjectSettings.set_initial_value(setting.name, setting.value)
	ProjectSettings.add_property_info({
		"name": setting.get("name"),
		"type": setting.get("type"),
		"hint": setting.get("hint", PROPERTY_HINT_NONE),
		"hint_string": setting.get("hint_string", "")
	})

func remove_setting(setting: Dictionary):
	if not ProjectSettings.has_setting(setting.name):
		return
	
	ProjectSettings.clear(setting.name)
