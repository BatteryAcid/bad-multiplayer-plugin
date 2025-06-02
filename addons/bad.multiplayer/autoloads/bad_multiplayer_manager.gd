extends Node

# TODO:
# - consider func to dis/enable BADNetworkEvents
# - add other things here that the user can use instead of worrying about calling other autoloades

# Autoloader
# Manages multiplayer functionality, use this script as the main way to access
# multiplayer functionalities.

enum AvailableNetworks {OFFLINE, ENET, NORAY, STEAM}
const DEDICATED_SERVER_FEATURE_NAME = "dedicated_server"

const NORAY_PLUGIN_PATH = "res://addons/netfox.noray/plugin.cfg"

# TODO: I'm not sure which way to set available networks for the game - plugin settings vs static config
# I guess this depends on how much we gain by disabling a plugin at the settings level??
# I think the Noray/Steam complementary addons should be disabled at the plugin level, that makes sense.
# However, how to reflect that back into the code here... not sure...
#
# IMFUCKINGPORTANT: Accessing with get_setting must use the same default value as the initial setting defined in the plugin.
# The get_setting will return null if you don't supply a default value that matches the default value in the setting configuration.
var network_types: Dictionary[BADMultiplayerManager.AvailableNetworks, bool] = {
	BADMultiplayerManager.AvailableNetworks.OFFLINE: ProjectSettings.get_setting(&"bad.multiplayer/networks/offline", true),
	BADMultiplayerManager.AvailableNetworks.ENET: ProjectSettings.get_setting(&"bad.multiplayer/networks/enet", true),
	BADMultiplayerManager.AvailableNetworks.NORAY: ProjectSettings.get_setting(&"bad.multiplayer/networks/noray", false),
	BADMultiplayerManager.AvailableNetworks.STEAM: false,
} 

## Access major game scenes
var main_menu_scene
var game_scene
var loading_scene
# TODO: match over scene

func _enter_tree() -> void:
	_check_and_set_available_networks()

#func _ready() -> void:
	#_check_and_set_available_networks()
	
func _check_and_set_available_networks():
	print(network_types)
	var enabled_plugins = ProjectSettings.get_setting("editor_plugins/enabled")
	print(enabled_plugins)
	var noray_plugin = null
	for enabled_plugin in enabled_plugins:
		if enabled_plugin == NORAY_PLUGIN_PATH:
			noray_plugin = enabled_plugin
			break
	if noray_plugin != null && network_types[BADMultiplayerManager.AvailableNetworks.NORAY]:
		network_types[BADMultiplayerManager.AvailableNetworks.NORAY] = true
	else:
		network_types[BADMultiplayerManager.AvailableNetworks.NORAY] = false
	print(network_types)	

func host_game(network_configs: BADNetworkConnectionConfigs):
	BADSceneManager.show_loading()
	
	if not BADNetworkManager.server_peer_created.is_connected(_on_peer_created):
		BADNetworkManager.server_peer_created.connect(_on_peer_created)
	
	BADNetworkManager.host_game(network_configs)

func join_game(network_configs: BADNetworkConnectionConfigs):
	BADSceneManager.show_loading()
	
	if not BADNetworkManager.client_peer_created.is_connected(_on_peer_created):
		BADNetworkManager.client_peer_created.connect(_on_peer_created)
	
	BADNetworkManager.join_game(network_configs)

func _on_peer_created():
	BADSceneManager.load_game()

func exit_gameplay_load_main_menu():
	_terminate_connection()
	BADSceneManager.load_main_menu()
	
func quit_game():
	_terminate_connection()
	get_tree().quit()

func _terminate_connection():
	BADNetworkManager.terminate_connection()
