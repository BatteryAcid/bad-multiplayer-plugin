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
	if BADMP.is_game_over():
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
		
		# This demonstrates where we don't need a custom MatchActionInfo, just
		# set the name of the action to perform
		BADMP.perform_match_action(BADMatchActionInfo.new(&"PlayerRespawnedAction"))

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
			print("Player %s health %s" % [name, _health])
		
		if _health <= 0 and not _player_dead:
			print("Marking player dead...")
			
			# This demonstrates a custom MatchActionInfo class that passes 
			# required data to perform the match action - in this case the player name
			var action_info = PlayerKilledAction.PlayerKilledActionInfo.new(name)
			BADMP.perform_match_action(action_info)
			
			_player_dead = true
			visible = false
			velocity = Vector2.ZERO
			_next_respawn_transform = BADMP.get_next_spawn_location(name)

func reset_health():
	if not is_multiplayer_authority():
		return
	_health = STARTING_HEALTH
