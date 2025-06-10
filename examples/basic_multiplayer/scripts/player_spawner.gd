extends BADPlayerSpawnHandler

# NOTE: Be careful if you need to override the _ready func, be sure to call to the super of it first!

# TODO: should this be called match handler instead?? or maybe we create a new handler that talks to the spawner?
# TODO: or maybe spawner should be an instance inside a gameplay manager? What this should be?


@export var match_wins_for_gameover = 2

@export var score_player1: RichTextLabel
@export var score_player2: RichTextLabel
@export var title_label: RichTextLabel
@export var winner_label: RichTextLabel
@export var match_info: Control
@export var play_again: Button
@export var end_game: Button

var game_over = false

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

# TODO: name this to match action or something, pass in object class instead, with impl here being whatever they want?
func player_killed(player_name: String):
	# TODO: lock this out when game is over
	if is_multiplayer_authority():
		print("****player_killed: %s" % player_name)
		
		# Set the index to the opposite of the player killed, as that's who 
		# gets the point
		var player_score_index = 0
		if player_name == "1":
			player_score_index = 1
		
		_player_scores[player_score_index] = _player_scores[player_score_index] + 1
		
		if _player_scores[player_score_index] >= match_wins_for_gameover:
			var winner = int(player_score_index) + 1
			print("Game over: %s wins!" % winner)
			var title_label = match_info.find_child("TitleLabel")
			title_label.text = "Game Over"
			var winner_label = match_info.find_child("WinnerLabel")
			winner_label.text = "Player %s Wins!" % winner
			
			# TODO: need to set game over state to end game
			# - need a way to reset everything, like a reset_game func
			game_over = true

		match_info.visible = true

func player_respawned(player_name: String):
	match_info.visible = false

func _physics_process(delta: float) -> void:
	if match_info.visible:
		# Do this here as a way to display the updated scores on non-host peers
		score_player1.text = str(_player_scores[0])
		score_player2.text = str(_player_scores[1])
	
	if game_over && multiplayer.has_multiplayer_peer() && is_multiplayer_authority():
		play_again.visible = true
		end_game.visible = true

func _on_play_again_pressed() -> void:
	print("play again")
	# TODO: move this to some reset function
	# - should this be part of the bad api?
	_player_scores = [0,0]
	title_label.text = "Scores"
	winner_label.text = ""
	score_player1.text = ""
	score_player2.text = ""
	play_again.visible = false
	end_game.visible = false
	match_info.visible = false
	game_over = false

func _on_end_game_pressed() -> void:
	print("end game")
	BADMultiplayerManager.exit_gameplay_load_main_menu()
