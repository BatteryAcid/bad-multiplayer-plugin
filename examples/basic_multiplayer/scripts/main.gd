extends Control

signal host_options_submitted
signal host_options_cancelled

signal join_options_submitted
signal join_options_cancelled

@export var main_options_panel: Panel
@export var host_btn: Button
@export var join_btn: Button
@export var host_options_panel_scene: PackedScene
@export var join_options_panel_scene: PackedScene

var _host_options_panel
var _join_options_panel

func _ready() -> void:
	# Inform BADMP of the main game scenes
	BADMP.add_scene(BADSceneManager.MAIN, "res://examples/basic_multiplayer/main.tscn")
	BADMP.add_scene(BADSceneManager.GAME, "res://examples/basic_multiplayer/game.tscn")
	BADMP.add_scene(BADSceneManager.LOADING, "res://examples/basic_multiplayer/loading.tscn")

	if BADMP.is_dedicated_server():
		print("Dedicated server build...")
		# NOTE: only supports ENet dedicated server builds
		BADMP.host_game(BADNetworkConnectionConfigs.new(BADMP.AvailableNetworks.ENET, "localhost"))
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
	BADMP.host_game(options)

func _on_host_options_cancelled():
	print("on host options cancelled")
	if _host_options_panel:
		_host_options_panel.queue_free()
	
	main_options_panel.visible = true
	host_btn.grab_focus()
	
func _on_join_options_submitted(options: BADNetworkConnectionConfigs):
	print("on join options submitted")
	BADMP.join_game(options)

func _on_join_options_cancelled():
	print("on join options cancelled")
	if _join_options_panel:
		_join_options_panel.queue_free()
	
	main_options_panel.visible = true
	host_btn.grab_focus()

func _on_exit_game_pressed() -> void:
	get_tree().quit()
