extends Control


#@export var network_types: Array[Node]
#@export var network_types: Dictionary
#@export var network_types: Array[BADNetworkType] = [BADNetworkType.new("asdf", "asdf")]
const ROOT = "res://addons/bad.multiplayer"

# Default Networks
# TODO: for now, they can manually update this list of available networks.
# - in a later version we can make it more config file based
# TODO: I think we actually need to move the real file paths dictionary of networks to this level
#enum AvailableNetworks {OFFLINE, ENET, NORAY, STEAM}

# TODO: this is not working... these are not being pulled from the settings...
# - break them out into their own or use separate plugins
var network_types: Dictionary[BADMultiplayerManager.AvailableNetworks, bool] = {
	BADMultiplayerManager.AvailableNetworks.OFFLINE: ProjectSettings.get_setting(&"BADMultiplayer/general/networks.values()[0]", false),
	BADMultiplayerManager.AvailableNetworks.ENET: ProjectSettings.get_setting(&"BADMultiplayer/general/networks/ENet", true),
	BADMultiplayerManager.AvailableNetworks.NORAY: ProjectSettings.get_setting(&"BADMultiplayer/general/networks/Noray", false),
	BADMultiplayerManager.AvailableNetworks.STEAM: ProjectSettings.get_setting(&"BADMultiplayer/general/networks/Steam", false),
}

@export_group("Game Scenes")
@export var active_scenes: Dictionary = {
	"main": "",
	"game": "",
	"loading": ""
}

# TODO: how to make multiple? Like a different menu for each network
# TODO: how to assign a menu per network
@export_group("NetworkMenus")
@export var submenu: Panel

@export_group("Host and Game Info")
@export var host_ip: LineEdit
@export var game_id: LineEdit

@export var host_btn: Button
@export var join_btn: Button

# Default to ENet, helpful for quick local testing
var _selected_network_type: int = BADMultiplayerManager.AvailableNetworks.ENET

func _ready() -> void:

	BADMultiplayerManager.main_menu_scene = active_scenes.main
	BADMultiplayerManager.game_scene = active_scenes.game
	BADMultiplayerManager.loading_scene = active_scenes.loading
	
	if OS.has_feature(BADMultiplayerManager.DEDICATED_SERVER_FEATURE_NAME):
		print("Dedicated server build...")
		# NOTE: only supports ENet dedicated server builds
		BADMultiplayerManager.host_game(BADNetworkConnectionConfigs.new(_selected_network_type, host_ip.text))
	else:
		print("Networks enabled: %s" % network_types)
		
		if host_btn != null:
			host_btn.connect("pressed", _on_host_game_pressed)
		else:
			print("No host game button provided!")
			
		if join_btn != null:
			join_btn.connect("pressed", _on_join_game_pressed)
		else:
			print("No join game button provided!")

func _on_host_game_pressed():
	print("host game hit...")
	if host_ip.text:
		BADMultiplayerManager.host_game(BADNetworkConnectionConfigs.new(_selected_network_type, host_ip.text))

func _on_join_game_pressed():
	print("Join game pressed...")
	if host_ip.text && game_id.text:
		BADMultiplayerManager.join_game(BADNetworkConnectionConfigs.new(_selected_network_type, host_ip.text, -1, game_id.text))
