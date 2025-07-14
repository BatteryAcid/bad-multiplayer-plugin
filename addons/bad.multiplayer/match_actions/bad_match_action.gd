@tool
@icon("res://addons/bad.multiplayer/icons/match-action-icon.svg")
class_name BADMatchAction
extends Node

# Reference to match action handler which should be the parent to custom actions
@onready var _match_action_handler = get_parent()

# TODO: consider using _notification instead of _ready
func _ready() -> void:
	_register_signal_for_action()

## Registers custom match action signal to the [method perform] function, that 
## must be overridden with the specific logic needed for the action
func _register_signal_for_action():
	get_action_signal().connect(perform)

## Emits signal tied custom action
func emit_action_signal(match_action_info: BADMatchActionInfo):
	get_action_signal().emit(match_action_info)

## Return custom signal from action subclass. Also provides access to action
## signal for use in other contexts.
func get_action_signal():
	pass

## Get reference to match action handler 
func get_match_action_handler():
	return _match_action_handler

## Override with specific logic performed for action
func perform(match_action_info: BADMatchActionInfo):
	pass
