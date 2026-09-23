@tool
extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

const SHEET = preload("res://assets/mushrooms.png")
const FRAME_SIZE = Vector2(40, 40) # < hard-coded ref to how big an individual sprite is

const BOB_HEIGHT_MIN = 1.0
const BOB_HEIGHT_MAX = 3.0
const BOB_DURATION_MIN = 0.8
const BOB_DURATION_MAX = 1.2
const ROTATION_DEGREES = 25.0

var frames: Array[AtlasTexture] = []

var current_health: int = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(_on_area_entered)
	sprite.animation_finished.connect(_on_animation_finished)
	_update_animation()
	
	if not Engine.is_editor_hint():
		sprite.rotation = deg_to_rad(randf_range(-ROTATION_DEGREES, ROTATION_DEGREES))
		_start_bob_tween()


func _start_bob_tween() -> void:
	var start_y = position.y
	var bob_height = randf_range(BOB_HEIGHT_MIN, BOB_HEIGHT_MAX)
	var bob_duration = randf_range(BOB_DURATION_MIN, BOB_DURATION_MAX)
	var tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", start_y - bob_height, bob_duration)
	tween.tween_property(self, "position:y", start_y + bob_height, bob_duration)


func _on_area_entered(area: Area2D) -> void:
	if area is LaserShot:
		current_health = max(current_health - 1, 0)
		_update_animation()
		area.deactivate() # < removes the laser shot
		#queue_free()


func _update_animation() -> void:
	var animation_name: StringName
	match current_health:
		3:
			animation_name = &"phase_1"
		2:
			animation_name = &"phase_2"
		1:
			animation_name = &"phase_3"
		0:
			animation_name = &"end_phase"

	sprite.play(animation_name)
	if animation_name == &"end_phase":
		sprite.sprite_frames.set_animation_loop(animation_name, false)
		collision_shape.queue_free()


func _on_animation_finished() -> void:
	if sprite.animation == &"end_phase":
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
