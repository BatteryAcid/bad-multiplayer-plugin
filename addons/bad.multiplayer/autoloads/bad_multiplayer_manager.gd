extends Node

# TODO:
# - consider func to dis/enable BADNetworkEvents
# - add other things here that the user can use instead of worrying about calling other autoloades

# Autoloader
# Manages multiplayer functionality, use this script as the main way to access
# multiplayer functionalities.

enum AvailableNetworks {OFFLINE, ENET, NORAY, STEAM}
const DEDICATED_SERVER_FEATURE_NAME = "dedicated_server"

# TODO: not used yet, just dumping here until I figure it out
# IMFUCKINGPORTANT: Accessing with get_setting must use the same default value as the initial setting defined in the plugin.
var network_types: Dictionary[BADMultiplayerManager.AvailableNetworks, bool] = {
	BADMultiplayerManager.AvailableNetworks.OFFLINE: ProjectSettings.get_setting(&"bad.multiplayer/networks/offline", true),
	BADMultiplayerManager.AvailableNetworks.ENET: ProjectSettings.get_setting(&"bad.multiplayer/networks/enet", true),
	BADMultiplayerManager.AvailableNetworks.NORAY: false,
	BADMultiplayerManager.AvailableNetworks.STEAM: false,
} 

#var asdf: bool = ProjectSettings.get_setting(&"bad.multiplayer/networks/offline", true)

## Access major game scenes
var main_menu_scene
var game_scene
var loading_scene

func _ready() -> void:
	print(network_types)
	#print(asdf)
	#print(ProjectSettings.get_setting("display/window/size/viewport_width"))
	#print(ProjectSettings.get_setting("bad_multiplayer/networks/enet"))
	
	

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
