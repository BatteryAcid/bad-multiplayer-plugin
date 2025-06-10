class_name Player
extends CharacterBody2D

const SPEED = 400.0
const STARTING_HEALTH: int = 5
const RESPAWN_TIME = 3
const ship_types: Array[String] = ["default", "ship2"]

@export var player_input: PlayerInput
@export var player_sprite: AnimatedSprite2D
@export var selected_ship: String = ship_types[0]

var _player_dead = false
var _health = 5
var _dead_timer = 0
var _next_respawn_transform = Transform2D(0, Vector2(-10, -10))

func _enter_tree():
	player_input.set_multiplayer_authority(str(name).to_int())

func _ready() -> void:
	player_sprite.animation = selected_ship

func _physics_process(_delta: float) -> void:
	# TODO: move to bad api
	if BADMultiplayerManager.is_game_over():
		return
	
	var input_dir = player_input.input_dir
	if input_dir:
		velocity.x = input_dir.x * SPEED
		velocity.y = input_dir.y * SPEED
	else:
		velocity.x = move_toward(input_dir.x, 0, SPEED)
		velocity.y = move_toward(input_dir.y, 0, SPEED)

	move_and_slide()
	
	if _dead_timer > RESPAWN_TIME:
		_dead_timer = 0
		_player_dead = false
		reset_health()
		visible = true
		BADMultiplayerManager.player_respawned(name)

	if _player_dead:
		if _dead_timer < 1:
			# we set this now, so it's ready once respawn has occured
			global_transform = _next_respawn_transform
		_dead_timer += _delta

func _register_hit(from: Player):
	# Ignore calls to hit from self
	if from == self:
		return
	
	if is_multiplayer_authority():
		if _health > 0:
			_health -= 1
			print("health %s" % _health)
		
		if _health <= 0 and not _player_dead:
			print("Marking player dead...")
			# TODO Move this to badmp 
			# TODO: I think this can be like action based, where we uses "keys" to identify what the action was, maybe even have a action class
			BADMultiplayerManager.player_killed(name)
			_player_dead = true
			visible = false
			velocity = Vector2.ZERO
			# TODO: this needs to be a badmp call
			_next_respawn_transform = BADMultiplayerManager.get_next_spawn_location(name)

func reset_health():
	if not is_multiplayer_authority():
		return
	_health = STARTING_HEALTH
