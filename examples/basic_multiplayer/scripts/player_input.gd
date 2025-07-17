class_name PlayerInput
extends Node

var input_dir : Vector2
var is_weapon_firing: bool = false

func _physics_process(_delta: float) -> void:
	# Freeze player inputs if game over
	if BADMP.is_game_over():
		return
	
	if get_tree().get_multiplayer().multiplayer_peer != null && is_multiplayer_authority():
		input_dir = Input.get_vector("left", "right", "up", "down")
		is_weapon_firing = Input.is_action_just_pressed("fire")
