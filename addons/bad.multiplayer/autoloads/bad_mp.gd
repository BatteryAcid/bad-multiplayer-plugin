extends Node
## [Autoloader]
## Contains the preferred way to access the BAD Multiplayer feature suite. You 
## can override the individual managers if necessary.

# TODO: consider func to dis/enable BADNetworkEvents
# TODO: display game id when using Noray, etc

var _multiplayer_manager = BADMultiplayerManager
var _network_manager = BADNetworkManager
var _scene_manager = BADSceneManager
var _network_events_manager = BADNetworkEvents
var _match_handler

enum AvailableNetworks {OFFLINE, ENET, NORAY, STEAM}

# IMPORTANT: Accessing with get_setting must use the same default value as the initial setting defined in the plugin.
# The get_setting will return null if you don't supply a default value that matches the default value in the setting configuration.
var available_networks: Dictionary = {
	AvailableNetworks.OFFLINE: {"script":"res://addons/bad.multiplayer/networks/offline_network.gd", "name": "OFFLINE_NETWORK", "enabled": ProjectSettings.get_setting(&"bad.multiplayer/networks/offline", true)},
	AvailableNetworks.ENET: {"script":"res://addons/bad.multiplayer/networks/enet_network.gd", "name": "ENET_NETWORK", "enabled": ProjectSettings.get_setting(&"bad.multiplayer/networks/enet", true)},
	AvailableNetworks.NORAY: {"script":"res://addons/bad.noray/networks/noray_network.gd", "name": "NORAY_NETWORK", "enabled": ProjectSettings.get_setting(&"bad.multiplayer/networks/noray", false)},
	AvailableNetworks.STEAM: {"script": "", "name": "STEAM_NETWORK", "enabled": false} #TODO: work this once supported
	# Add more networks here
}


## Host or Join game entry points

func host_game(network_configs: BADNetworkConnectionConfigs):
	_multiplayer_manager.host_game(network_configs)

func join_game(network_configs: BADNetworkConnectionConfigs):
	_multiplayer_manager.join_game(network_configs)


## Utilities 

## Use to add supported game scenes
func add_scene(scene_name: String, scene_path: String):
	_scene_manager.add_enabled_game_scene(scene_name, scene_path)
	
func is_game_over():
	if _match_handler:
		return _match_handler.game_over

# TODO: this should be something more generic, like update score or something
# TODO: create object to hold this info
# TODO: i think this should be player_state_changed, and pass in a dictionary that can switch/case whatever states
func player_killed(player_name: String):
	print("Player killed: %s" % player_name)
	if _match_handler:
		_match_handler.player_killed(player_name)

func player_respawned(player_name: String):
	print("Player respawned: %s" % player_name)
	if _match_handler:
		_match_handler.player_respawned(player_name)

# TODO: also need to consider if using states for game over/game play/loading etc...
# TODO: not sure we should make this part of the api, as not all games have respawns
func get_next_spawn_location(player_name: String):
	if _match_handler:
		return _match_handler.get_spawn_point(player_name)

func exit_gameplay_load_main_menu():
	get_multiplayer_manager().exit_gameplay_load_main_menu()

func is_dedicated_server():
	return OS.has_feature("dedicated_server")

func set_game_id(available_network: AvailableNetworks, game_id: String):
	available_networks[available_network]["game_id"] = game_id

func get_game_id(available_network: AvailableNetworks):
	return available_networks[available_network].game_id

## Getters and setters

## Use this to override the BADMultiplayerManager with a custom one.
func set_multiplayer_manager(multiplayer_manager):
	_multiplayer_manager = multiplayer_manager
	
func get_multiplayer_manager():
	return _multiplayer_manager

## Use this to override the BADNetworkManager with a custom one.
func set_network_manager(network_manager):
	_network_manager = network_manager

func get_network_manager():
	return _network_manager

## Use this to override the BADSceneManager with a custom one.
func set_scene_manager(scene_manager):
	_scene_manager = scene_manager

func get_scene_manager():
	return _scene_manager

## Use this to override the BADNetworkEvents with a custom one.
func set_network_events_manager(network_events_manager):
	_network_events_manager = network_events_manager

func get_network_events_manager():
	return _network_events_manager

func set_match_manager(match_handler):
	_match_handler = match_handler
	
func get_match_manager():
	return _match_handler
