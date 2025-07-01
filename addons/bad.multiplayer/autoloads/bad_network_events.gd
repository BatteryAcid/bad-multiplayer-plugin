extends Node
## [Autoloader]
## Listens for network events and rebroadcasts them in effort to normalize these
## events regardless of network type.
## 
## NOTE: If you want to use [OfflineMultiplayerPeer] for gameplay, you may need 
## to remove the check from [method is_server] below so that it doesn't return
## false.[br]
## [codeblock]if peer is OfflineMultiplayerPeer:
##     return false
## [/codeblock][br]
##
## Based on Netfox's NetworkEvents: [br]
## https://github.com/foxssake/netfox/blob/main/addons/netfox/network-events.gd

## Event emitted when the [MultiplayerAPI] is changed
signal on_multiplayer_change(old: MultiplayerAPI, new: MultiplayerAPI)

## Event emitted when the server starts
signal on_server_start()

## Event emitted when the server stops for any reason
signal on_server_stop()

## Event emitted when the client starts
signal on_client_start(id: int)

## Event emitted when the client stops.
##
## This can happen due to either the client itself or the server disconnecting
## for whatever reason.
signal on_client_stop()

## Event emitted when a new peer joins the game.
signal on_peer_join(id: int)

## Event emitted when a peer leaves the game.
signal on_peer_leave(id: int)

## Whether the events are enabled.
##
## Events are only emitted when it's enabled. Disabling this can free up some 
## performance, as when enabled, the multiplayer API and the host are
## continuously checked for changes.
##
var enabled: bool:
	get: return _enabled
	set(v): _set_enabled(v)

var _multiplayer: MultiplayerAPI
var _enabled: bool = false
var _is_server: bool = false

func _ready() -> void:
	print("BADNetworkEvents ready")
	enabled = false # Set this here to force the "enable" setup to run

func _process(_delta: float) -> void:	
	if multiplayer != _multiplayer:
		_disconnect_handlers(_multiplayer)
		_connect_handlers(multiplayer)
		
		on_multiplayer_change.emit(_multiplayer, multiplayer)
		_multiplayer = multiplayer
	
	if not _is_server and is_server():
		_is_server = true
		on_server_start.emit()
		
	if _is_server and not is_server():
		_is_server = false
		on_server_stop.emit()

## Check if we're running as server.
func is_server() -> bool:
	if multiplayer == null:
		return false
	
	var peer := multiplayer.multiplayer_peer
	if peer == null:
		return false
	
	# NOTE: if you want to leverage on_server_start/stop signals while "offline"
	# like if using OfflineMultiplayerPeer, you may want to remove this check.
	#if peer is OfflineMultiplayerPeer:
		#return false
		
	if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return false
	
	if not multiplayer.is_server():
		return false
	
	return true

func _connect_handlers(mp: MultiplayerAPI) -> void:
	if mp == null:
		return

	mp.connected_to_server.connect(_handle_connected_to_server)
	mp.server_disconnected.connect(_handle_server_disconnected)
	mp.peer_connected.connect(_handle_peer_connected)
	mp.peer_disconnected.connect(_handle_peer_disconnected)

func _disconnect_handlers(mp: MultiplayerAPI) -> void:
	if mp == null:
		return

	mp.connected_to_server.disconnect(_handle_connected_to_server)
	mp.server_disconnected.disconnect(_handle_server_disconnected)
	mp.peer_connected.disconnect(_handle_peer_connected)
	mp.peer_disconnected.disconnect(_handle_peer_disconnected)
	
# For use only on clients
func _handle_connected_to_server() -> void:
	on_client_start.emit(multiplayer.get_unique_id())

# For use only on clients
func _handle_server_disconnected() -> void:
	on_client_stop.emit()

func _handle_peer_connected(id: int) -> void:
	on_peer_join.emit(id)

func _handle_peer_disconnected(id: int) -> void:
	on_peer_leave.emit(id)

func _set_enabled(enable: bool) -> void:
	if _enabled and not enable:
		_disconnect_handlers(_multiplayer)
		_multiplayer = null
	if not _enabled and enable:
		_multiplayer = multiplayer
		_connect_handlers(_multiplayer)

	_enabled = enable
	set_process(enable)
	
func unset_server_flag():
	_is_server = false
