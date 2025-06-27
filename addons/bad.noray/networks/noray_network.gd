class_name noray_network 
extends BADNetwork

# TODO:
# - may have to disable NetworkEvents to not clash with BADNetworkEvents, this is only when netfox enabled
# - At the bottom, when Netfox enabled, must stop time in terminate_connection, I think...
# - Could have option to select NAT and/or Relay

var _port = 8890
var _current_host_oid = ""

func _ready():
	print("Noray network ready!")
	if BADNetworkManager.is_host:
		setup_host_noray_connection_signals()
	else:
		setup_client_noray_connection_signals()

# Hosting Noray - entry point
func create_server_peer(network_configs: BADNetworkConnectionConfigs):
	print("Create Noray server peer")
	var err = await _register_with_noray(network_configs.host_ip)
	if err == OK:
		err = await _start_noray_host()
	else:
		print("Failed to register with Noray")
	
	return err
	
# Joining Noray as client - entry point
func create_client_peer(network_configs: BADNetworkConnectionConfigs):
	print("create Noray client peer")
	var err = OK
	# Stash the game id (oid)
	_current_host_oid = network_configs.game_id
	err = await _register_with_noray(network_configs.host_ip)
	if err != OK:
		print("Client registration with Noray failed!")
		return err

	# TODO: just use relay when testing at home
	#Noray.connect_nat(game_id)
	Noray.connect_relay(network_configs.game_id)
	return err

func _register_with_noray(host_ip: String):
	print("Register with Noray hosted at: %s" % host_ip)
	var err = OK
	
	# connect to Noray
	err = await Noray.connect_to_host(host_ip, _port)
	if err != OK:
		print("Failed to connect to Noray for registration at %s:%s, %s" % [host_ip, _port, err])
		return err
		
	# Register host
	Noray.register_host()
	await Noray.on_pid
	
	# Capture game_id to display on host-peer for sharing with others
	print("Noray oid/gameId: %s" % Noray.oid)
	BADNetworkManager.active_game_id = Noray.oid

	# Register remove address
	err = await Noray.register_remote()
	if err != OK:
		print("Failed to register remote %s" % err)
		return err
	
	print("Finished Noray registration")
	return err

func _start_noray_host():
	print("Starting Noray host")
	var err = OK
	
	var noray_network_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	err = noray_network_peer.create_server(Noray.local_port)
	if err != OK:
		print("Failed to listen on port %s with error: %s" % [Noray.local_port, err])

	get_tree().get_multiplayer().multiplayer_peer = noray_network_peer

	# Wait for server to start
	# Wait for the connection status to change away from Connecting, whether it's successful or not
	await BADAsync.condition(
		func(): return noray_network_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTING
	)
	
	if noray_network_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		OS.alert("Failed to start server!")
		err = FAILED

	return err

# This is called on the host once a client is detected
func _handle_noray_client_connect(address: String, port: int) -> Error:
	print("Noray host handle connect: %s:%s" % [address, port])
	var peer = get_tree().get_multiplayer().multiplayer_peer as ENetMultiplayerPeer
	var err = await PacketHandshake.over_enet(peer.host, address, port)
	
	if err != OK:
		print("Noray packet handshake failed %s" % err)
		return err

	print("Handshake to %s:%s concluded" % [address, port])
	return OK

func _handle_nat_connect(address: String, port: int) -> Error:
	print("Attempting to connect client via NAT: %s:%s" % [address, port])
	var err = await _handle_connect(address, port)
	if err != OK:
		print("NAT connection failed from client, trying Relay instead...")
		Noray.connect_relay(_current_host_oid)
		return OK
	else:
		print("NAT punchthrough successful!")
	return err
	
func _handle_relay_connect(address: String, port: int) -> Error:
	print("Attempting to connect client via Relay: %s:%s" % [address, port])
	return await _handle_connect(address, port)

func _handle_connect(address: String, port: int) -> Error:
	print("Client handle connect to %s:%s, Noray.localport: %s" % [address, port, Noray.local_port])
	
	# Do a handshake
	var udp = PacketPeerUDP.new()
	udp.bind(Noray.local_port)
	udp.set_dest_address(address, port)

	var err = await PacketHandshake.over_packet_peer(udp) # 8 is default
	udp.close()
	
	if err != OK:
		if err == ERR_BUSY:
			print("Handshake to %s:%s succeeded partially, attempting connection anyway" % [address, port])
		else:
			print("Client packet handshake failed %s" % err)
			BADMP.exit_gameplay_load_main_menu()
			return err
	else:
			print("Handshake to %s:%s succeeded" % [address, port])

	# Connect to host
	var peer = ENetMultiplayerPeer.new()
	err = peer.create_client(address, port, 0, 0, 0, Noray.local_port)
	
	if err != OK:
		print("Create client failed %s" % err)
		return err

	get_tree().get_multiplayer().multiplayer_peer = peer
	
	# Wait for the connection status to change away from Connecting, whether it's successful or not
	await BADAsync.condition(
		func(): return peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTING
	)
		
	if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		print("Failed to connect to %s:%s with status %s" % [address, port, peer.get_connection_status()])
		get_tree().get_multiplayer().multiplayer_peer = null
		
		# Connection failed, reset
		BADMP.exit_gameplay_load_main_menu()
		
		return ERR_CANT_CONNECT
	else:
		print("connection to relay done")

	return OK

# Noray connection signals
func setup_host_noray_connection_signals():
	Noray.on_connect_nat.connect(_handle_noray_client_connect)
	Noray.on_connect_relay.connect(_handle_noray_client_connect)

func setup_client_noray_connection_signals():
	Noray.on_connect_nat.connect(_handle_nat_connect)
	Noray.on_connect_relay.connect(_handle_relay_connect)

func terminate_connection():
	Noray.disconnect_from_host()
	# NetworkTime.stop() # TODO: Netfox API- would need to integrate this somehow...
	
	if multiplayer != null && multiplayer.has_multiplayer_peer():
		get_tree().get_multiplayer().multiplayer_peer = null
