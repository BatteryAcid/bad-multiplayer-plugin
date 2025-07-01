extends Node
## Holds reference and manages changing to major game scenes. Supports main menu,
## loading, and game scenes by default. Add more game scenes with 
## [method add_enabled_game_scene].[br][br]
## 
## Autoloader BADSceneManager
##

## Default scenes
const MAIN = "main"
const LOADING = "loading"
const GAME = "game"

## Add to this if you want to support more scenes
var _enabled_game_scenes: Dictionary[String, String] = {}

## Add game scene
func add_enabled_game_scene(scene_name: String, scene_path: String):
	_enabled_game_scenes[scene_name] = scene_path

## Use this to load non-default scenes that have been added to enabled game scenes
func load_scene(scene_name: String):
	var scene_path = _enabled_game_scenes[scene_name]
	get_tree().call_deferred(&"change_scene_to_packed", load(scene_path))

func load_main_menu():
	load_scene(MAIN)

func load_game():
	load_scene(GAME)

func show_loading():
	load_scene(LOADING)
