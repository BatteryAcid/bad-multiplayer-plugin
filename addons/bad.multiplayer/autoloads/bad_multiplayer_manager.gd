extends Node
## [Autoloader]
## Coordinates network connection signals, shows/hides loading and game scenes.
## Also checks for enabled external networking options like Noray.

const NORAY_PLUGIN_PATH = "res://addons/netfox.noray/plugin.cfg"

func host_game(network_configs: BADNetworkConnectionConfigs):
	BADMP.get_scene_manager().show_loading()
	
	if not BADMP.get_network_manager().server_peer_created.is_connected(_on_peer_created):
		BADMP.get_network_manager().server_peer_created.connect(_on_peer_created)
	
	BADMP.get_network_manager().host_game(network_configs)

func join_game(network_configs: BADNetworkConnectionConfigs):
	BADMP.get_scene_manager().show_loading()
	
	if not BADMP.get_network_manager().client_peer_created.is_connected(_on_peer_created):
		BADMP.get_network_manager().client_peer_created.connect(_on_peer_created)
	
	BADMP.get_network_manager().join_game(network_configs)

func exit_gameplay_load_main_menu():
	_terminate_connection()
	BADMP.get_scene_manager().load_main_menu()
	
func quit_game():
	_terminate_connection()
	get_tree().quit()
	
func _enter_tree() -> void:
	_check_and_set_available_networks()

func _check_and_set_available_networks():
	var enabled_plugins = ProjectSettings.get_setting("editor_plugins/enabled")

	# TODO: probably refactor how this works to be more dynamic
	var noray_plugin = null
	for enabled_plugin in enabled_plugins:
		if enabled_plugin == NORAY_PLUGIN_PATH:
			noray_plugin = enabled_plugin
			break

	if noray_plugin != null && BADMP.available_networks[BADMP.AvailableNetworks.NORAY].enabled:
		BADMP.available_networks[BADMP.AvailableNetworks.NORAY].enabled = true
	else:
		BADMP.available_networks[BADMP.AvailableNetworks.NORAY].enabled = false
		
	print("Enabled networks: %s" % BADMP.available_networks)	

func _on_peer_created():
	BADMP.get_scene_manager().load_game()

func _terminate_connection():
	BADMP.get_network_manager().terminate_connection()
