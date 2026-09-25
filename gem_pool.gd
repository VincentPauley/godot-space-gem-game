extends Node2D

@export var gem_scene: PackedScene

@onready var gem_tile_layout: TileMapLayer = $"../TileMapLayer"

var cell_size: Vector2i
var grid_coords: Array[Vector2i] = []

var gem_map: Dictionary = {}

func register_gem_destroyed(gem_coord: Vector2i) -> void:
	gem_map[gem_coord] = false
	print('updated map with deleted gem: ')
	print(JSON.stringify(gem_map, "\t"))

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
		gem_map[coord] = true # < register active gem to map
		
		var gem = gem_scene.instantiate()
		gem.position = gem_tile_layout.map_to_local(coord)
		gem.gem_coord = coord

		add_child(gem)
		# ^ now every gem is a child of the pool
		gem_tile_layout.erase_cell(coord)
	
	print(JSON.stringify(gem_map, "\t"))



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
