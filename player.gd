@tool
extends CharacterBody2D

@onready var sprite: Sprite2D = %Sprite2D
@onready var shooter_location: Marker2D = %ShooterLocation
@onready var projectile_pool: ProjectilePool = get_parent().get_node("ProjectilePool")

const SHEET = preload("res://assets/3-ships-for-kids.png")
const FRAME_SIZE = Vector2(100, 110) # < hard-coded ref to how big an individual sprite is

const SPEED = 500.0
const ACCELERATION = 1200.0
const DECELERATION = 900.0
const BOB_AMPLITUDE = 3.0
const BOB_FREQUENCY = 1.0

var skins: Array[AtlasTexture] = []
var window_width: int = 0
var bob_time: float = 0.0
var base_y: float
var previous_input_direction: float = 0.0
var lane_target_x: float = 0.0
var lane_tween: Tween
var lane_tween_duration: float = 0.0
var lane_tween_elapsed: float = 0.0
var lane_tween_start_x: float = 0.0
var lane_positions: Array[float] = []
var lane_positions_cached: bool = false

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
		if lane_tween != null and lane_tween.is_running():
			_interrupt_lane_tween()
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	elif previous_input_direction != 0:
		if _select_lane_target():
			if abs(velocity.x) > 0.5:
				_start_lane_tween()
			else:
				position.x = lane_target_x
				velocity.x = 0.0
		else:
			velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
	elif lane_tween != null and lane_tween.is_running():
		lane_tween_elapsed = min(lane_tween_elapsed + delta, lane_tween_duration)
		velocity.x = 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
	previous_input_direction = direction


func _get_lane_positions() -> Array[float]:
	if not lane_positions_cached:
		for marker in get_tree().get_nodes_in_group("player_lane_markers"):
			if marker is Node2D:
				lane_positions.append(get_parent().to_local(marker.global_position).x)
		lane_positions.sort()
		lane_positions_cached = true
	return lane_positions


func _select_lane_target() -> bool:
	var available_lanes = _get_lane_positions()
	if available_lanes.is_empty():
		return false

	var stopping_distance = velocity.x * abs(velocity.x) / (2.0 * DECELERATION)
	var projected_stop_x = position.x + stopping_distance
	var travel_direction = sign(velocity.x)
	var best_distance = INF
	for lane_x in available_lanes:
		if travel_direction != 0 and (lane_x - position.x) * travel_direction < 0:
			continue
		var distance_to_projected_stop = abs(lane_x - projected_stop_x)
		if distance_to_projected_stop < best_distance:
			best_distance = distance_to_projected_stop
			lane_target_x = lane_x

	if best_distance == INF:
		lane_target_x = available_lanes[0]
		for lane_x in available_lanes:
			if abs(lane_x - projected_stop_x) < abs(lane_target_x - projected_stop_x):
				lane_target_x = lane_x
	return true


func _start_lane_tween() -> void:
	var distance_to_lane = abs(lane_target_x - position.x)
	if distance_to_lane <= 0.5:
		position.x = lane_target_x
		velocity.x = 0.0
		return

	lane_tween_start_x = position.x
	lane_tween_duration = 2.0 * distance_to_lane / abs(velocity.x)
	lane_tween_elapsed = 0.0
	lane_tween = create_tween()
	lane_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	lane_tween.set_trans(Tween.TRANS_QUAD)
	lane_tween.set_ease(Tween.EASE_OUT)
	lane_tween.tween_property(self, "position:x", lane_target_x, lane_tween_duration)
	lane_tween.finished.connect(_on_lane_tween_finished)
	velocity.x = 0.0


func _interrupt_lane_tween() -> void:
	var progress = clamp(lane_tween_elapsed / lane_tween_duration, 0.0, 1.0)
	var initial_velocity = 2.0 * (lane_target_x - lane_tween_start_x) / lane_tween_duration
	velocity.x = initial_velocity * (1.0 - progress)
	lane_tween.kill()
	lane_tween = null


func _on_lane_tween_finished() -> void:
	position.x = lane_target_x
	velocity.x = 0.0
	lane_tween = null


func _clamp_to_window() -> void:
	var available_lanes = _get_lane_positions()
	if available_lanes.is_empty():
		position.x = clamp(position.x, 0.0, window_width)
		return
	position.x = clamp(position.x, available_lanes.front(), available_lanes.back())


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
