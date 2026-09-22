extends Area2D
class_name LaserShot

@export var speed: float = 600.0

var velocity: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	z_index = -1 # render behind the player
	velocity = Vector2(0, -speed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta
