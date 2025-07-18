@tool
@icon("res://addons/bad.multiplayer/icons/match-action-handler-icon.svg")
class_name BADMatchHandler
extends Node
## Attach this script to a Node in your game scene, to aid in spawning players
## based off network events. To be used along side a [MultiplayerSpawner].[br]
##
## Also handles custom "actions" you may want to perform during a match, such as
## player killed, player respawned, etc. Nest BADMatchAction implementations
## under this node, they will be automatically registered. Run them with
## [method perform_match_action].[br][br]
##
## The default implementation:[br]
##  - Spawns player once a connection is made, despawns after disconnected[br]
##  - Tracks a list of active players[br]
##  - Sets the name to the [i]network_id[/i] of the peer[br][br]
## 
## If you want to use most of the default functionality, it's likely at a 
## minimum, you'll want to override the [method ready_player] function to set 
## custom player properties (player name, spawn location, etc) for when your 
## player spawns in game. Otherwise, override any mix of functions. Also good 
## place to connect in game menu signals.

const GAME_PLAY_STATE = "game_play"
const GAME_OVER_STATE = "game_over"

@export var player_scene: PackedScene
@export var player_spawn_point: Node
@export var match_actions: Dictionary = {}

var _players_in_game: Dictionary = {}
var _match_state: String = ""

func _enter_tree() -> void:
	register_match_manager()
	
## Registers the match manager with BADMP once it's loaded in game. Override to
## use a different match manager.
func register_match_manager():
	BADMP.set_match_manager(self)
	
func _ready() -> void:
	print("BADMatchHandler Ready!")

	if BADMP.get_network_manager().is_host:
		# Only needed on host peer
		BADMP.get_network_events_manager().on_server_start.connect(on_server_start)
		BADMP.get_network_events_manager().on_server_stop.connect(on_server_stop)
		BADMP.get_network_events_manager().on_peer_join.connect(on_peer_join)
		BADMP.get_network_events_manager().on_peer_leave.connect(on_peer_leave)
	else:
		# Client peer signals
		BADMP.get_network_events_manager().on_client_stop.connect(on_client_stop)
	
	# This prevents the on_server_start signals from getting fired before the game scene is loaded...
	BADMP.get_network_events_manager().enabled = true
	
	_register_match_actions()

func on_server_start():
	print("Handle host start")
	# Don't add a player to the game if host is a dedicated server
	if not BADMP.is_dedicated_server():
		add_player_to_game(1)

func on_server_stop():
	print("Handle host stop")
	# Remove players from game
	for player in _players_in_game.values():
		player.queue_free()
	_players_in_game.clear()
	
	# After host-stop signal is processed, disable BAD network events as we are
	# no longer a host with an active connection. This is critical for the
	# network events to correctly reset once a new connection is established
	BADMP.get_network_events_manager().enabled = false

# This will only be called when other peers connect, not when adding the 
# host-player to the scene
func on_peer_join(network_id: int):
	add_player_to_game(network_id)
	
func on_peer_leave(network_id: int):
	remove_player_from_game(network_id)
	
# Only called when from external connection closed event. This will not fire if
# the player exits the game play, as they are moved back to main menu scene
# before this can be hit.
func on_client_stop():
	print("Client disconnected")
	# After client disconnects, reset BAD network events. This is critical for
	# the network events to correctly reset once a new connection is established
	BADMP.get_network_events_manager().enabled = false
	BADMP.exit_gameplay_load_main_menu()

# TODO: should this be a match event?
# - Right now I'm thinking no, since it's likely these 3 actions will happen in
# every match-style game. Match events are for those specific to a game.
func add_player_to_game(network_id: int):
	if is_multiplayer_authority():
		print("Adding player to game: %s" % network_id)

		if _players_in_game.get(network_id) == null:
			var player_to_add = player_scene.instantiate()

			ready_player(network_id, player_to_add)

			_players_in_game[network_id] = player_to_add
			player_spawn_point.add_child(player_to_add)
		else:
			print("Warning! Attempted to add existing player to game: %s" % network_id)

# TODO: should this be a match event?
func remove_player_from_game(network_id: int):
	if is_multiplayer_authority():
		print("Removing player from game: %s" % network_id)
		if _players_in_game.has(network_id):
			var player_to_remove = _players_in_game[network_id]
			if player_to_remove:
				player_to_remove.queue_free()
				_players_in_game.erase(network_id)

# TODO: should this be a match event?
## Setup initial or reload saved player properties
func ready_player(network_id: int, player: Variant):
	if is_multiplayer_authority():
		player.name = str(network_id)
		player.global_transform = get_spawn_point(player.name)
		
		# Player is always owned by the server
		player.set_multiplayer_authority(1)

# TODO: should this be a match event?
## Override with custom spawn point logic
func get_spawn_point(data: Variant) -> Variant:
	return

func get_players_in_game():
	return _players_in_game


## Match State

func get_match_state():
	return _match_state

func set_match_state(state_: String):
	if state_:
		_match_state = state_
	
func is_match_state_active(state_to_check: String) -> bool:
	return state_to_check == _match_state


## Establishes custom match actions added to the match action handler
func _register_match_actions():
	for child in find_children("*", "BADMatchAction", false):
		# print("Registering match action: %s" % child.name)
		match_actions[child.name] = child

## Performs the action defined within the custom match action
func perform_match_action(match_action_info: BADMatchActionInfo):
	# print("Performing match action: %s" % match_action_info.get_match_action_name())
	
	if not match_actions.has(match_action_info.get_match_action_name()):
		print("Match action does not exist! %s" % match_action_info.get_match_action_name())
		return
		
	var match_action = match_actions.get(match_action_info.get_match_action_name())
	match_action.emit_action_signal(match_action_info)
