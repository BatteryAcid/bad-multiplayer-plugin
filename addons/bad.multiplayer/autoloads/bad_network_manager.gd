extends Node
## [Autoloader]
## Manages the active network

signal server_peer_created
signal client_peer_created

var is_host = false
var active_host_ip = ""

var _active_network_node: BADNetwork

# Establishes a host/server peer based on selected network
func host_game(network_configs: BADNetworkConnectionConfigs):
	print("Hosting game: %s with network type: %s" % [network_configs.host_ip, network_configs.network_type])
	
	is_host = true
	active_host_ip = network_configs.host_ip
	
	# The active network node must be added to the Tree in order to access the
	# multiplayer APIs
	_active_network_node = _instantiate_network_scene(network_configs.network_type)
	add_child(_active_network_node)

	network_configs.host_port = _active_network_node.get_port()
	var err = await _active_network_node.create_server_peer(network_configs)
	
	if err == OK:
		print("Finished creating server peer")
		server_peer_created.emit()
	else:
		print("Failed to create server peer...")

# Attempts to connect to a host/server peer based on selected network
func join_game(network_configs: BADNetworkConnectionConfigs):
	print("Joining game at host: %s, with game id: %s, and network type: %s" % [network_configs.host_ip, network_configs.game_id, network_configs.network_type])
	is_host = false
	
	_active_network_node = _instantiate_network_scene(network_configs.network_type)
	add_child(_active_network_node)

	network_configs.host_port = _active_network_node.get_port()
	var err = await _active_network_node.create_client_peer(network_configs)
	
	if err == OK:
		print("Finished creating client peer")
		# NOTE: Potential race condition: If this signal is delayed, meaning 
		# after the peer establishes a connection and we don't switch to game 
		# scene in time, the server (upon getting on_peer_connected) will fail
		# to spawn the player, as the local peer hasn't loaded the game scene
		client_peer_created.emit()

	else:
		print("Failed to create client peer...")
		BADMP.exit_gameplay_load_main_menu()

func terminate_connection():
	print("BADNetworkManager terminate_connection...")

	if not is_host:
		# Handles the case where a client leaves game, terminates connection,
		# not from a server-sourced disconnect.
		BADMP.get_network_events_manager().enabled = false
		_remove_client_signals()
	else:
		_remove_host_signals()
		
	is_host = false
	active_host_ip = ""
	
	_destroy_active_network()
	
	# Make sure player has mouse access to select menu options
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _instantiate_network_scene(selected_network_type: int) -> BADNetwork:
	var selected_network = BADMP.available_networks[selected_network_type]
	var selected_network_script = selected_network.script
	
	# Use load for dynamically loaded scripts
	var bad_network_script = load(selected_network_script)
	var bad_network_node = bad_network_script.new()
	
	bad_network_node.set_script(bad_network_script)
	bad_network_node.name = selected_network.name
	
	return bad_network_node

func _destroy_active_network():
	if _active_network_node != null:
		# Call to the active network specific connection cleanup
		_active_network_node.terminate_connection()
		# Remove active network node from tree
		_active_network_node.queue_free()

# Used to cleanup host signals after disconnection
func _remove_host_signals():
	var server_created_signal_connections = \
		server_peer_created.get_connections()
		
	for conn in server_created_signal_connections:
		server_peer_created.disconnect(conn.callable)

# Used to cleanup client signals after disconnection
func _remove_client_signals():
	var client_created_signal_connections = \
		client_peer_created.get_connections()
		
	for conn in client_created_signal_connections:
		client_peer_created.disconnect(conn.callable)
