extends Area2D

@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D

const BOB_HEIGHT_MIN = 1.0
const BOB_HEIGHT_MAX = 3.0
const BOB_DURATION_MIN = 0.8
const BOB_DURATION_MAX = 1.2

const gem_options = ['green', 'pink']
var option = 'green' # < defaulting to green but there is likely a better way

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_determine_gem_type()
	_determine_animation()
	_start_bob_tween()

func _determine_animation() -> void:
	if option == 'green':
		sprite.play('green_phase_1')
	if option == 'pink':
		sprite.play('pink_phase_1')
	
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
