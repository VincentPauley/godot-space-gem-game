@tool
extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

const SHEET = preload("res://assets/mushrooms.png")
const FRAME_SIZE = Vector2(40, 40) # < hard-coded ref to how big an individual sprite is

const BOB_HEIGHT_MIN = 1.0
const BOB_HEIGHT_MAX = 3.0
const BOB_DURATION_MIN = 0.8
const BOB_DURATION_MAX = 1.2

var frames: Array[AtlasTexture] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
	if not Engine.is_editor_hint():
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
		area.deactivate()
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
