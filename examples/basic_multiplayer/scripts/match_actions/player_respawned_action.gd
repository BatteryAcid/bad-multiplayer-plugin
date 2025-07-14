class_name PlayerRespawnedAction
extends BADMatchAction

signal player_respawned

func get_action_signal():
	return player_respawned

func perform(match_action_info: BADMatchActionInfo):
	if is_multiplayer_authority():
		# This only needs to be set on the authority, as it's replicated
		get_match_action_handler().match_info.visible = false
