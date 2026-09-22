extends Node2D

# this manages all the laser shot nodes used by the player so that nodes get reused
# rather than constantly creating new nodes and removing them which is very costly to performance

@export var projectile_scene: PackedScene

const POOL_SIZE = 10

var pool: Array[LaserShot] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialize_pool()

func _initialize_pool() -> void:
	for i in range(POOL_SIZE):
		var laser_shot = projectile_scene.instantiate()
		add_child(laser_shot)
		# TODO: init as hidden and deactivated		
		pool.append(laser_shot)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
