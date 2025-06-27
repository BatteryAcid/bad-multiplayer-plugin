@tool
extends EditorPlugin

const ROOT = "res://addons/bad.multiplayer"

var SETTINGS = [
	{
		# Setting this to false will make BADMultiplayer keep its settings 
		# even when disabling the plugin. Useful for developing the plugin.
		"name": "bad.multiplayer/general/clear_settings",
		"value": false,
		"type": TYPE_BOOL
	},
	{
		"name": "bad.multiplayer/networks/enet",
		"value": true,
		"type": TYPE_BOOL
	},
	{
		"name": "bad.multiplayer/networks/offline",
		"value": true,
		"type": TYPE_BOOL
	}
]

const AUTOLOADS = [
	{
		"name": "BADMultiplayerManager",
		"path": ROOT + "/autoloads/bad_multiplayer_manager.gd"
	},
	{
		"name": "BADNetworkManager",
		"path": ROOT + "/autoloads/bad_network_manager.gd"
	},
	{
		"name": "BADNetworkEvents",
		"path": ROOT + "/autoloads/bad_network_events.gd"
	},
	{
		"name": "BADSceneManager",
		"path": ROOT + "/autoloads/bad_scene_manager.gd"
	},
	{
		"name": "BADMP",
		"path": ROOT + "/autoloads/bad_mp.gd"
	},
]

func _enter_tree() -> void:
	print("BAD Multiplayer enter_tree...")
	
	for setting in SETTINGS:
		add_setting(setting)

	for autoload in AUTOLOADS:
		add_autoload_singleton(autoload.name, autoload.path)

func _exit_tree() -> void:
	print("BAD Multiplayer exit_tree...")
	if ProjectSettings.get_setting(&"bad.multiplayer/general/clear_settings", false):
		for setting in SETTINGS:
			remove_setting(setting)
			
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
