class_name PlayerInput
extends Node

var input_dir : Vector2
var is_weapon_firing: bool = false

func _physics_process(_delta: float) -> void:
	if get_tree().get_multiplayer().multiplayer_peer != null && is_multiplayer_authority():
		input_dir = Input.get_vector("left", "right", "up", "down")
		is_weapon_firing = Input.is_action_pressed("fire")
