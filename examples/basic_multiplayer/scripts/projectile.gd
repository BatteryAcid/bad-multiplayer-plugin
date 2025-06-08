extends Area2D

@export var MAX_DISTANCE: float = 1600.0
@export var speed: float = 600.0
@export var _projectile_sprite: AnimatedSprite2D

var fire_dir: int = 1
var fired_by: Player

var _distance_left: float

func _ready() -> void:
	_distance_left = MAX_DISTANCE
	
	# Set direction of projectile's animation
	if fire_dir < 0:
		_projectile_sprite.flip_h = false

func _physics_process(delta: float) -> void:
	var dist = speed * delta
	_distance_left -= dist

	if _distance_left < 0:
		queue_free()
		print("Removing projectile")

	translate(Vector2(fire_dir * dist, 0))

func _on_body_entered(body):
	# print("Blaster hit: %s" % body.name)
	
	# Ignore hits to self
	if body == fired_by:
		return
	
	if body is Player:
		print("Player %s hit! " % body.name)
		if fired_by != null:
			body._register_hit(fired_by)
	
	# Clean up object whenever it hits something that's not the player firing it	
	_impact_on_hit()

func _impact_on_hit():
	print("Impact on hit")
	speed = 0 # stop on impact
	
	#await get_tree().create_timer(1).timeout # used this to allow for explosion animation, not supported atm
	queue_free()
