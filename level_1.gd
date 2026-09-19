extends Node2D

@export var player_scene: PackedScene
@export var mushroom_scene: PackedScene


@onready var tile_map_layer = %TileMapLayer

var cell_size: Vector2i
var grid_coords: Array[Vector2i] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_read_tile_grid()
	_spawn_player_to_center()
	_spawn_mushrooms()


func _read_tile_grid() -> void:
	cell_size = tile_map_layer.tile_set.tile_size
	grid_coords = tile_map_layer.get_used_cells()
	


func _spawn_player_to_center() -> void:
	var player = player_scene.instantiate()

	var window_size: Vector2i = get_window().size
	var center_point = window_size.x / 2

	player.position.x = center_point
	player.position.y = window_size.y - 100
	
	add_child(player)


func _spawn_mushrooms() -> void:
	for coord in grid_coords:
		tile_map_layer.erase_cell(coord)
		
		var mushroom = mushroom_scene.instantiate()
		mushroom.position = tile_map_layer.map_to_local(coord)
		tile_map_layer.add_child(mushroom)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
