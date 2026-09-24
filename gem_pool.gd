extends Node2D

@export var gem_scene: PackedScene

@onready var gem_tile_layout: TileMapLayer = $"../TileMapLayer"

var cell_size: Vector2i
var grid_coords: Array[Vector2i] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	read_gem_tile_layout()
	spawn_gems()
	
func read_gem_tile_layout() -> void:
	cell_size = gem_tile_layout.tile_set.tile_size
	grid_coords = gem_tile_layout.get_used_cells()

func spawn_gems() -> void:
	# this loop places a gem at every used tile spot.	
	for coord in grid_coords:
		var gem = gem_scene.instantiate()
		gem.position = gem_tile_layout.map_to_local(coord)
		gem_tile_layout.add_child(gem)

	
		# remove tile in filler in future
		#tile_map_layer.erase_cell(coord)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
