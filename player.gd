extends CharacterBody2D

@onready var sprite: Sprite2D = %Sprite2D

const SHEET = preload("res://assets/3-ships-for-kids.png")
const FRAME_SIZE = Vector2(100, 110) # < hard-coded ref to how big an individual sprite is

var skins: Array[AtlasTexture] = []
var window_width: int = 0

func _ready() -> void:
	_build_skins()
	sprite.texture = skins[0]
	
	window_width = get_window().size.x
	
func _build_skins() -> void:
	for i in range(3):
		var atlas = AtlasTexture.new()
		atlas.atlas = SHEET
		atlas.region = Rect2(i * FRAME_SIZE.x, 0,  FRAME_SIZE.x, FRAME_SIZE.y)
		skins.append(atlas)


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("left"):
		position.x -= 8
	if Input.is_action_pressed("right"):
		position.x += 8
	
	# keep player within x boundaries
	var player_half_width: float = FRAME_SIZE.x / 2.0
	position.x = clamp(position.x, player_half_width, window_width - player_half_width)


#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0


#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
