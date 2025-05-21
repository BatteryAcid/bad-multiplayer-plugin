extends Node

# Autoloader

func load_main_menu():
	get_tree().call_deferred(&"change_scene_to_packed", load(BADMultiplayerManager.main_menu_scene))

func load_game():
	get_tree().call_deferred(&"change_scene_to_packed", load(BADMultiplayerManager.game_scene))

func show_loading():
	get_tree().call_deferred(&"change_scene_to_packed", load(BADMultiplayerManager.loading_scene))
