# TODO: can probably be remove, or refactor to use this, not sure. Related to settings/ menu
class_name BADNetworkType
extends Node

enum AvailableNetworks {OFFLINE, ENET, NORAY, STEAM}

var network_type: String
var network_scene: String  

func _init(network_type_: String, network_scene_: String) -> void:
	network_type = network_type_
	network_scene = network_scene_
