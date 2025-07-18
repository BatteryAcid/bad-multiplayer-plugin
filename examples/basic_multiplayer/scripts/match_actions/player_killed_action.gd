class_name PlayerKilledAction
extends BADMatchAction

signal player_killed

@onready var _match_handler = get_match_action_handler()	

func get_action_signal():
	return player_killed

func perform(match_action_info: BADMatchActionInfo):
	if is_multiplayer_authority():
		print("Player killed: %s" % (match_action_info as PlayerKilledActionInfo).player_name)
		
		# Set the index to the opposite of the player killed, as that's who 
		# gets the point
		var player_score_index = 0
		if match_action_info.player_name == "1":
			player_score_index = 1
		
		_match_handler._player_scores[player_score_index] = _match_handler._player_scores[player_score_index] + 1
		
		if _match_handler._player_scores[player_score_index] >= _match_handler.match_wins_for_gameover:
			var winner = int(player_score_index) + 1
			print("Game over: %s wins!" % winner)
			var title_label = _match_handler.match_info.find_child("TitleLabel")
			title_label.text = "Game Over"
			var winner_label = _match_handler.match_info.find_child("WinnerLabel")
			winner_label.text = "Player %s Wins!" % winner
			
			_match_handler.set_match_state(_match_handler.GAME_OVER_STATE)

		_match_handler.match_info.visible = true

## Used to hold information specific to containing-parent action
class PlayerKilledActionInfo extends BADMatchActionInfo:

	var player_name: String
	
	func _init(player_name_: String) -> void:
		super(&"PlayerKilledAction")
		player_name = player_name_
