extends Control

signal host_options_submitted
signal host_options_cancelled

signal join_options_submitted
signal join_options_cancelled


@export var main_options_panel: Panel

@export var host_btn: Button
@export var join_btn: Button

#@export var _main_scene: PackedScene

@export var host_options_panel_scene: PackedScene
@export var join_options_panel_scene: PackedScene

var _host_options_panel
var _join_options_panel


func _ready() -> void:

	#print(ProjectSettings.get_setting("bad.multiplayer/networks/enet"))
	#print(ProjectSettings.get_setting("bad.multiplayer/networks/offline"))
	#
	# TODO: Move this to badmp autoloader
	# - could also provide default scenes? probably not, as you'd have to know how the scores work, etc
	# Establish game scenes
	BADMultiplayerManager.main_menu_scene = "res://examples/basic_multiplayer/main.tscn"
	BADMultiplayerManager.game_scene = "res://examples/basic_multiplayer/game.tscn"
	BADMultiplayerManager.loading_scene = "res://examples/basic_multiplayer/loading.tscn"
	
	if OS.has_feature(BADMultiplayerManager.DEDICATED_SERVER_FEATURE_NAME):
		print("Dedicated server build...")
		# NOTE: only supports ENet dedicated server builds
		BADMultiplayerManager.host_game(BADNetworkConnectionConfigs.new(BADMultiplayerManager.AvailableNetworks.ENET, "localhost"))
	else:
		host_options_submitted.connect(_on_host_options_submitted)
		host_options_cancelled.connect(_on_host_options_cancelled)
		
		join_options_submitted.connect(_on_join_options_submitted)
		join_options_cancelled.connect(_on_join_options_cancelled)
		
		host_btn.grab_focus()

func _on_host_game_pressed():
	print("host game hit...")
	if host_options_panel_scene:
		main_options_panel.visible = false
		_host_options_panel = host_options_panel_scene.instantiate()
		add_child(_host_options_panel)

func _on_join_game_pressed():
	print("Join game pressed...")
	if join_options_panel_scene:
		main_options_panel.visible = false
		_join_options_panel = join_options_panel_scene.instantiate()
		add_child(_join_options_panel)

func _on_host_options_submitted(options: BADNetworkConnectionConfigs):
	print("on host options submitted")
	BADMultiplayerManager.host_game(options)

func _on_host_options_cancelled():
	print("on host options cancelled")
	if _host_options_panel:
		_host_options_panel.queue_free()
	
	main_options_panel.visible = true
	host_btn.grab_focus()
	
func _on_join_options_submitted(options: BADNetworkConnectionConfigs):
	print("on join options submitted")
	BADMultiplayerManager.join_game(options)

func _on_join_options_cancelled():
	print("on join options cancelled")
	if _join_options_panel:
		_join_options_panel.queue_free()
	
	main_options_panel.visible = true
	host_btn.grab_focus()

func _on_exit_game_pressed() -> void:
	get_tree().quit()
