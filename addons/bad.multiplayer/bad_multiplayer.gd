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
	#{
		#"name": "BADMultiplayer/general/networks",
		#"value": {"Offline": true, "ENet": true, "Noray": false, "Steam": false},
		#"type": TYPE_DICTIONARY
	#}
	# TODO: can we disable BADNetworkEvents
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
	#{
		#"name": "Async",
		#"path": ROOT + "/autoloads/bad_async.gd"
	#}
	#,
	#{
		#"name": "Noray",
		#"path": ROOT + "/autoloads/bad_noray_mock.gd"
	#}
]

const TYPES: Array[Dictionary] = [
	#{
		#"name": "BADMultiplayerOptions",
		#"base": "Control",
		#"script": ROOT + "/bad_multiplayer_options.gd",
		#"icon": "res://icon.svg"#ROOT + "/icons/rollback-synchronizer.svg"
	#}
	# TODO: don't think we'll need a custom Node, just make users override script,
	#{
		#"name": "BADPlayerSpawner",
		#"base": "Node",
		#"script": ROOT + "/bad_player_spawner.gd",
		#"icon": "res://icon.svg"#ROOT + "/icons/rollback-synchronizer.svg"
	#}
]

func _enter_tree() -> void:
	print("BAD Multiplayer enter_tree...")
	
	for setting in SETTINGS:
		add_setting(setting)
	
	# TODO: probably wont need this, using settings
	#if not EditorInterface.is_plugin_enabled("netfox.noray"):
		#print("Netfox's Noray NOT enabled")
	
	for autoload in AUTOLOADS:
		add_autoload_singleton(autoload.name, autoload.path)

	for type in TYPES:
		add_custom_type(type.name, type.base, load(type.script), load(type.icon))

func _exit_tree() -> void:
	print("BAD Multiplayer exit_tree...")
	if ProjectSettings.get_setting(&"bad.multiplayer/general/clear_settings", false):
		for setting in SETTINGS:
			remove_setting(setting)
			
	for autoload in AUTOLOADS:
		remove_autoload_singleton(autoload.name)

	for type in TYPES:
		remove_custom_type(type.name)

func add_setting(setting: Dictionary):
	if ProjectSettings.has_setting(setting.name):
		return

	print("adding setting %s with value: %s " % [setting.name, setting.value])
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
