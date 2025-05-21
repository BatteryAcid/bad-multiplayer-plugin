class_name Player
extends CharacterBody2D

const SPEED = 400.0
const ship_types: Array[String] = ["default", "ship2"]

@export var player_input: PlayerInput
@export var player_sprite: AnimatedSprite2D
@export var selected_ship: String = ship_types[0]

func _enter_tree():
	player_input.set_multiplayer_authority(str(name).to_int())

func _ready() -> void:
	player_sprite.animation = selected_ship

func _physics_process(_delta: float) -> void:
	var input_dir = player_input.input_dir
	if input_dir:
		velocity.x = input_dir.x * SPEED
		velocity.y = input_dir.y * SPEED
	else:
		velocity.x = move_toward(input_dir.x, 0, SPEED)
		velocity.y = move_toward(input_dir.y, 0, SPEED)

	move_and_slide()
