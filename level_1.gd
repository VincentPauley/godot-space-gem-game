extends Node2D

@export var player_scene: PackedScene
@export var lane_marker_scene: PackedScene
@export var centipede_scene: PackedScene

@onready var tile_map_layer = %TileMapLayer

var cell_size: Vector2i
var grid_coords: Array[Vector2i] = []

var PLAYER_Y_BASE = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var window_size: Vector2i = get_window().size

	PLAYER_Y_BASE = window_size.y - 100
	
	var centipede = centipede_scene.instantiate()
	centipede.configure(tile_map_layer, $GemPool)
	add_child(centipede)
	
	_read_tile_grid()
	_spawn_player_to_center()
	_place_lane_indicators()


func _read_tile_grid() -> void:
	cell_size = tile_map_layer.tile_set.tile_size
	grid_coords = tile_map_layer.get_used_cells()

func _place_lane_indicators() -> void:
	var column_width = cell_size.x
	
	var column_count = get_window().size.x / column_width

	for i in column_count:
		var column = (i + 1)
		var column_center = column * column_width - (column_width /2)

		var lane_marker = lane_marker_scene.instantiate()
		lane_marker.add_to_group("player_lane_markers")
		lane_marker.position = Vector2i(column_center, PLAYER_Y_BASE)
		lane_marker.hide()
		add_child(lane_marker)


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
