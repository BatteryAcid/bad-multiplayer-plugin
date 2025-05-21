class_name PlayerInput
extends Node

var input_dir : Vector2

func _physics_process(_delta: float) -> void:
	if get_tree().get_multiplayer().multiplayer_peer != null && is_multiplayer_authority():
		input_dir = Input.get_vector("left", "right", "up", "down")
