extends Node2D

@export var player_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawn_player_to_center()


func _spawn_player_to_center() -> void:
	var player = player_scene.instantiate()

	var window_size: Vector2i = get_window().size
	var center_point = window_size.x / 2

	player.position.x = center_point
	player.position.y = window_size.y - 100
	
	add_child(player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
