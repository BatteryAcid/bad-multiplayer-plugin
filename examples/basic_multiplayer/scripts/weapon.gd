extends Node2D

const FIRE_COOLDOWN = .5

@export var input: PlayerInput
@export var projectile: PackedScene

var _parent_player
var _next_fire_available = FIRE_COOLDOWN + 1 # add one so player is able to fire

func _ready() -> void:
	_parent_player = get_parent()

func _physics_process(delta: float) -> void:
	if input.is_weapon_firing && _next_fire_available > FIRE_COOLDOWN:
		_next_fire_available = 0
		var projectile = _spawn_projectile()
	else:
		_next_fire_available += delta

func _spawn_projectile():
	var blaster_projectile: Area2D = projectile.instantiate() as Area2D

	# Puts the projectile right under the wing
	blaster_projectile.global_transform = _parent_player.global_transform.translated(Vector2(0, 18))
	blaster_projectile.fired_by = _parent_player
	
	if not _parent_player.name == "1": # if not host
		blaster_projectile.fire_dir = -1
		#fire_out.offset.x = 5 TODO: remove, used for spawn animation

	# We add these here and not at the root of the tree so that when we move away from the Game scene
	# it will clean everything up
	get_tree().current_scene.find_child("Projectiles").add_child(blaster_projectile, true)
		
	return blaster_projectile	
