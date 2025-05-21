class_name enet_network 
extends BADNetwork

const DEFAULT_PORT = 8080

func create_server_peer(network_configs: BADNetworkConnectionConfigs):
	var enet_network_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	enet_network_peer.create_server(network_configs.host_port)
	get_tree().get_multiplayer().multiplayer_peer = enet_network_peer
	#await get_tree().create_timer(3).timeout # TODO: remove, for testing
	return OK

func create_client_peer(network_configs: BADNetworkConnectionConfigs):
	var enet_network_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	print("%s : %s" % [network_configs.host_ip, network_configs.host_port])
	enet_network_peer.create_client(network_configs.host_ip, network_configs.host_port)
	get_tree().get_multiplayer().multiplayer_peer = enet_network_peer
	return OK

func get_port():
	return DEFAULT_PORT

func terminate_connection():
	if multiplayer != null && multiplayer.has_multiplayer_peer():
		get_tree().get_multiplayer().multiplayer_peer = null
		#TODO get_tree().get_multiplayer().multiplayer_peer = OfflineMultiplayerPeer.new()
