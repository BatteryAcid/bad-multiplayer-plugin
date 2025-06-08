extends BADPlayerSpawnHandler

# NOTE: Be careful if you need to override the _ready func, be sure to call to the super of it first!

# TODO: should this be called match handler instead?? or maybe we create a new handler that talks to the spawner?

@export var score_player1: RichTextLabel
@export var score_player2: RichTextLabel
@export var match_over: Control

var _player_scores: Array = [0,0]

# Setup initial or reload saved player properties
func ready_player(network_id: int, player: Player):
	if is_multiplayer_authority():
		print("****ready_player")
		player.name = str(network_id)
		player.global_transform = get_spawn_point(player.name)
		
		if player.name != "1":
			player.selected_ship = player.ship_types[1]

		# Player is always owned by the server
		player.set_multiplayer_authority(1)

func get_spawn_point(player_name) -> Transform2D:
	print("****get_spawn_point")
	if player_name == "1": # For now, just check if you're the host, spawn on left side.
		return Transform2D(0, Vector2(randi_range(75, 275), randi_range(50, 570)))
	else:
		return Transform2D(0, Vector2(randi_range(1400, 1600), randi_range(50, 570)))

func player_killed(player_name: String):
	if is_multiplayer_authority():
		print("****player_killed: %s" % player_name)
		
		# Set the index to the opposite of the player killed, as that's who 
		# gets the point
		var player_score_index = 0
		if player_name == "1":
			player_score_index = 1
		
		_player_scores[player_score_index] = _player_scores[player_score_index] + 1

		match_over.visible = true

func player_respawned(player_name: String):
	match_over.visible = false

func _physics_process(delta: float) -> void:
	if match_over.visible:
		# Do this here as a way to display the updated scores on non-host peers
		score_player1.text = str(_player_scores[0])
		score_player2.text = str(_player_scores[1])
