class_name offline_network 
extends BADNetwork

# OfflineMultiplayerPeer: A MultiplayerPeer which is always connected and acts as a server.

func create_server_peer(network_connection_configs: BADNetworkConnectionConfigs):
	var offline_network_peer: OfflineMultiplayerPeer = OfflineMultiplayerPeer.new()
	get_tree().get_multiplayer().multiplayer_peer = offline_network_peer
	return OK

func terminate_connection():
	if multiplayer != null && multiplayer.has_multiplayer_peer():
		get_tree().get_multiplayer().multiplayer_peer = null
