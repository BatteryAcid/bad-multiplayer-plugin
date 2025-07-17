extends BADMatchHandler
## Example usage of (overriding) BADMatchHandler. Override functions to suit
## the needs of your game. Also good place to connect in game menu signals.

# NOTE: Be careful if you need to override the _ready func, be sure to call to the super of it first!
# TODO: consider using _notification instead of _ready for setup.

@export var match_wins_for_gameover = 2
@export var score_player1: RichTextLabel
@export var score_player2: RichTextLabel
@export var title_label: RichTextLabel
@export var winner_label: RichTextLabel
@export var match_info: Control
@export var play_again: Button
@export var end_game: Button

var _player_scores: Array = [0,0]

# Setup initial or reload saved player properties
func ready_player(network_id: int, player: Variant):
	if is_multiplayer_authority():
		player.name = str(network_id)
		player.global_transform = get_spawn_point(player.name)
		
		if player.name != "1":
			player.selected_ship = player.ship_types[1]

		# Player is always owned by the server
		player.set_multiplayer_authority(1)

func get_spawn_point(player_name) -> Transform2D:
	if player_name == "1": # For now, just check if you're the host, spawn on left side.
		return Transform2D(0, Vector2(randi_range(75, 275), randi_range(50, 570)))
	else:
		return Transform2D(0, Vector2(randi_range(1400, 1600), randi_range(50, 570)))

func _physics_process(delta: float) -> void:
	if match_info.visible:
		# Do this here as a way to display the updated scores on non-host peers
		score_player1.text = str(_player_scores[0])
		score_player2.text = str(_player_scores[1])
	
	if BADMP.is_game_over() && multiplayer.has_multiplayer_peer() && is_multiplayer_authority():
		play_again.visible = true
		end_game.visible = true

func _on_play_again_pressed() -> void:
	print("Play again")
	_reset_match()

func _on_end_game_pressed() -> void:
	print("End game")
	BADMP.exit_gameplay_load_main_menu()
	
func _reset_match():
	_player_scores = [0,0]
	title_label.text = "Scores"
	winner_label.text = ""
	score_player1.text = ""
	score_player2.text = ""
	play_again.visible = false
	end_game.visible = false
	match_info.visible = false
	set_match_state(GAME_PLAY_STATE)
