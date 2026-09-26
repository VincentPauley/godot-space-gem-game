@tool
extends CharacterBody2D

@onready var sprite: Sprite2D = %Sprite2D
@onready var shooter_location: Marker2D = %ShooterLocation
@onready var projectile_pool: ProjectilePool = get_parent().get_node("ProjectilePool")

const SHEET = preload("res://assets/3-ships-for-kids.png")
const FRAME_SIZE = Vector2(100, 110) # < hard-coded ref to how big an individual sprite is

const SPEED = 500.0
const ACCELERATION = 3000.0
const DECELERATION = 2500.0
const BOB_AMPLITUDE = 3.0
const BOB_FREQUENCY = 1.0

var skins: Array[AtlasTexture] = []
var window_width: int = 0
var bob_time: float = 0.0
var base_y: float

func _ready() -> void:
	_build_skins()
	sprite.texture = skins[0]
	
	window_width = get_window().size.x
	base_y = position.y
	
	
	
func _build_skins() -> void:
	for i in range(3):
		var atlas = AtlasTexture.new()
		atlas.atlas = SHEET
		atlas.region = Rect2(i * FRAME_SIZE.x, 0,  FRAME_SIZE.x, FRAME_SIZE.y)
		skins.append(atlas)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	bob_time += delta
	position.y = base_y + sin(bob_time * TAU * BOB_FREQUENCY) * BOB_AMPLITUDE
	_apply_movement(delta)
	move_and_slide()
	if Input.is_action_just_pressed("fire"):
		_handle_fire()
	_clamp_to_window()

func _handle_fire() -> void:
	var projectile = projectile_pool.get_projectile()
	if projectile == null:
		return
	projectile.global_position = shooter_location.global_position
	projectile.spawn()



func _get_input_direction() -> float:
	return Input.get_axis("left", "right")


func _apply_movement(delta: float) -> void:
	var direction: float = _get_input_direction()
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)


func _clamp_to_window() -> void:
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
