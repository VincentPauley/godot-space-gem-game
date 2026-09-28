extends Node2D

signal gems_positioned

@export var gem_scene: PackedScene
  
@onready var gem_tile_layout: TileMapLayer = $"../TileMapLayer"

# Vertical distance above the final position where each gem starts its entrance.
const ENTRANCE_OFFSET = Vector2(0, -500)
# Time in seconds for the bottom row to travel from its offset to its final position.
const ENTRANCE_DURATION = 0.7
# Additional seconds added to each higher row, making it move progressively slower.
const ENTRANCE_DURATION_STEP = 0.12
# Delay between starting each row; rows can overlap while earlier rows are still moving.
const ROW_START_INTERVAL = 0.05

var cell_size: Vector2i
var grid_coords: Array[Vector2i] = []

var gem_map: Dictionary = {}
var gems: Array[Area2D] = []
var entrance_rows_positioned: int = 0
var entrance_rows_total: int = 0
var entrance_complete: bool = false

func is_gem_at(coord: Vector2i) -> bool:
	return gem_map.get(coord, false)

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
	# Spawn every gem above its target, then animate the whole group into place.
	for coord in grid_coords:
		gem_map[coord] = true # < register active gem to map
		
		var gem = gem_scene.instantiate()
		var final_position = gem_tile_layout.map_to_local(coord)
		gem.position = final_position + ENTRANCE_OFFSET
		gem.gem_coord = coord
		gem.bobbing_enabled = false

		add_child(gem)
		gems.append(gem)
		# ^ now every gem is a child of the pool
		gem_tile_layout.erase_cell(coord)
	
	#print(JSON.stringify(gem_map, "\t"))
	_start_gem_entrance()

func _start_gem_entrance() -> void:
	if gems.is_empty():
		_on_gems_positioned()
		return

	var row_values: Array[int] = []
	for gem in gems:
		if gem.gem_coord.y not in row_values:
			row_values.append(gem.gem_coord.y)
	row_values.sort()
	row_values.reverse()
	entrance_rows_positioned = 0
	entrance_rows_total = row_values.size()

	for row_index in row_values.size():
		var row_tween = create_tween()
		row_tween.set_parallel()
		row_tween.set_trans(Tween.TRANS_QUAD)
		row_tween.set_ease(Tween.EASE_OUT)
		var duration = ENTRANCE_DURATION + row_index * ENTRANCE_DURATION_STEP
		for gem in gems:
			if gem.gem_coord.y == row_values[row_index]:
				var final_position = gem_tile_layout.map_to_local(gem.gem_coord)
				row_tween.tween_property(gem, "position", final_position, duration)
		row_tween.finished.connect(_on_row_positioned.bind(row_values[row_index]))
		if row_index < row_values.size() - 1:
			await get_tree().create_timer(ROW_START_INTERVAL).timeout

func _on_row_positioned(row_y: int) -> void:
	entrance_rows_positioned += 1
	for gem in gems:
		if gem.gem_coord.y == row_y:
			gem.begin_bobbing()
	if entrance_rows_positioned == entrance_rows_total:
		_on_gems_positioned()

func _on_gems_positioned() -> void:
	entrance_complete = true
	gems_positioned.emit()
	print("All gems are positioned")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
