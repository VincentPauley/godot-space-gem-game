extends Area2D

@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = %CollisionShape2D

const BOB_HEIGHT_MIN = 1.0
const BOB_HEIGHT_MAX = 3.0
const BOB_DURATION_MIN = 0.8
const BOB_DURATION_MAX = 1.2
const ROTATION_DEGREES = 25.0

const gem_options = ['green', 'pink']
var option = 'green' # < defaulting to green but there is likely a better way

var current_health: int = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_determine_gem_type()
	_determine_animation()
	area_entered.connect(_on_area_entered)
	sprite.animation_finished.connect(_on_animation_finished)
	
	if not Engine.is_editor_hint():
		sprite.rotation = deg_to_rad(randf_range(-ROTATION_DEGREES, ROTATION_DEGREES))
		_start_bob_tween()

func _determine_animation() -> void:
	var animation_name = ''
	
	if option == 'green' and current_health == 3:
		animation_name = 'green_phase_1'
	if option == 'green' and current_health == 2:
		animation_name = 'green_phase_2'
	if option == 'green' and current_health == 1:
		animation_name = 'green_phase_3'
	if option == 'green' and current_health <= 0:
		animation_name = 'green_end_phase'
	if option == 'pink' and current_health == 3:
		animation_name = 'pink_phase_1'
	if option == 'pink' and current_health == 2:
		animation_name = 'pink_phase_2'
	if option == 'pink' and current_health == 1:
		animation_name = 'pink_phase_3'
	if option == 'pink' and current_health <= 0:
		animation_name = 'pink_end_phase'
		
	sprite.play(animation_name)
	if animation_name == "pink_end_phase" or animation_name == "green_end_phase":
		sprite.sprite_frames.set_animation_loop(animation_name, false)
		collision_shape.queue_free()
	
func _determine_gem_type() -> void:
	option = gem_options[randi() % 2]
	
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
		area.deactivate()
		current_health -= 1
		_determine_animation()

# NOTE: this is separate from collision removal because we want lasers to pas
# through while explosion is taking place
func _on_animation_finished() -> void:
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
