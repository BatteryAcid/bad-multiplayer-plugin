@tool
@icon("res://addons/bad.multiplayer/match-action-info-icon.svg")
class_name BADMatchActionInfo
extends Node
## Override with fields needed for the custom match action.[br]
## Can be used as a nested class within the match action.

func get_match_action_name() -> StringName:
	return &""
