extends Control

func _ready() -> void:
	BADMP.add_scene(BADSceneManager.MAIN, "res://examples/getting_started/scenes/main_menu.tscn")
	BADMP.add_scene(BADSceneManager.GAME, "res://examples/getting_started/scenes/game.tscn")
	BADMP.add_scene(BADSceneManager.LOADING, "res://examples/getting_started/scenes/loading.tscn")

func _on_host_pressed() -> void:
	var configs_host: = BADNetworkConnectionConfigs.new(BADMP.AvailableNetworks.ENET, "localhost")
	BADMP.host_game(configs_host)

func _on_join_game_pressed() -> void:
	var configs_join: = BADNetworkConnectionConfigs.new(BADMP.AvailableNetworks.ENET, "localhost", 8080)
	BADMP.join_game(configs_join)
