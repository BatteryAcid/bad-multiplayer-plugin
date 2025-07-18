@tool
@icon("res://addons/bad.multiplayer/icons/match-action-info-icon.svg")
class_name BADMatchActionInfo
extends Node
## Override with fields needed for the custom match action.[br]
## Can be used as a nested class within the match action.

var _match_action_name: StringName

func _init(match_action_name: StringName = &"") -> void:
	_match_action_name = match_action_name

func get_match_action_name() -> StringName:
	return _match_action_name
