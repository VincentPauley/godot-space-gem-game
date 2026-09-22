extends Node2D
class_name ProjectilePool
# this manages all the laser shot nodes used by the player so that nodes get reused
# rather than constantly creating new nodes and removing them which is very costly to performance

@export var projectile_scene: PackedScene

const POOL_SIZE = 20

var pool: Array[LaserShot] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialize_pool()
	
func get_projectile() -> LaserShot:
	for projectile in pool:
		if not projectile.is_active:
			return projectile
			
	push_error('no inactive projectile available.')
	return null

func _initialize_pool() -> void:
	for i in range(POOL_SIZE):
		var laser_shot = projectile_scene.instantiate()
		add_child(laser_shot)
		laser_shot.deactivate()
		pool.append(laser_shot)
