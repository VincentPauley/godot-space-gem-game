extends Area2D
class_name LaserShot

@export var speed: float = 600.0

var is_active: bool = false

var velocity: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	z_index = -1 # render behind the player
	velocity = Vector2(0, -speed)

func deactivate() -> void:
	is_active = false
	hide()
	set_process(false)
	$CollisionShape2D.disabled = false

func spawn() -> void:
	is_active = true
	show()
	set_process(true)
	$CollisionShape2D.disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_active:
		return
	position += velocity * delta

# use child node to detect when off screen
func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	deactivate()
