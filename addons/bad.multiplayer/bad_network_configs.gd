class_name BADNetworkConnectionConfigs
extends Resource

@export var network_type: int = -1 
@export var host_ip: String = ""
@export var host_port: int = -1
@export var game_id: String = ""

func _init(network_type_: int, host_ip_: String, host_port_: int = -1, game_id_: String = ""):
	network_type = network_type_
	host_ip = host_ip_
	host_port = host_port_
	game_id = game_id_
