extends Area2D
class_name CentipedeHead

const MOVE_INTERVAL = 0.3
const MOVE_DURATION = 0.24
const SCREEN_EDGE_MARGIN = 18.0

var tile_map_layer: TileMapLayer
var gem_pool: Node
var min_cell: Vector2i
var max_cell: Vector2i
var current_cell: Vector2i
var horizontal_direction: int = -1
var is_configured: bool = false
var has_started: bool = false
var movement_finished: bool = false
var descent_pending: bool = false

func configure(grid: TileMapLayer, gem_state: Node) -> void:
	tile_map_layer = grid
	gem_pool = gem_state
	is_configured = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(_on_area_entered)
	if not is_configured or gem_pool.grid_coords.is_empty():
		push_error("CentipedeHead requires a configured grid with cells")
		queue_free()
		return

	var grid_coords: Array[Vector2i] = gem_pool.grid_coords
	min_cell = grid_coords[0]
	max_cell = grid_coords[0]
	for cell in grid_coords:
		min_cell.x = mini(min_cell.x, cell.x)
		min_cell.y = mini(min_cell.y, cell.y)
		max_cell.x = maxi(max_cell.x, cell.x)
		max_cell.y = maxi(max_cell.y, cell.y)
	while _cell_is_on_screen(Vector2i(min_cell.x, max_cell.y + 1)):
		max_cell.y += 1

	hide()
	gem_pool.gems_positioned.connect(_on_gems_positioned)
	if gem_pool.entrance_complete:
		_on_gems_positioned()


func _on_gems_positioned() -> void:
	# prevent duplicate starts and resets
	if has_started:
		return
	# init centipede in top right position and begin it's movment.
	current_cell = Vector2i(max_cell.x, min_cell.y)
	global_position = _cell_to_global(current_cell)
	has_started = true
	show()
	_run_movement()


func _run_movement() -> void:
	while is_inside_tree() and not movement_finished:
		await get_tree().create_timer(MOVE_INTERVAL).timeout
		if not is_inside_tree():
			return
		await _move_one_cell()

func _move_one_cell() -> bool:
	if descent_pending:
		if await _try_descend():
			descent_pending = false
			return true
		return await _sweep_horizontally()

	var next_horizontal_cell = current_cell + Vector2i(horizontal_direction, 0)
	if not _is_horizontal_cell_blocked(next_horizontal_cell):
		await _move_to_cell(next_horizontal_cell)
		return true

	# A wall or gem starts descent search; turn around and try the cell below now.
	descent_pending = true
	horizontal_direction *= -1
	if await _try_descend():
		descent_pending = false
		return true
	return await _sweep_horizontally()


func _is_horizontal_cell_blocked(cell: Vector2i) -> bool:
	return (
		cell.x < min_cell.x
		or cell.x > max_cell.x
		or gem_pool.is_gem_at(cell)
		or not _cell_is_on_screen(cell)
	)


func _try_descend() -> bool:
	var cell_below = current_cell + Vector2i.DOWN
	if (
		not gem_pool.is_gem_at(cell_below)
		and _cell_is_on_screen(cell_below)
	):
		await _move_to_cell(cell_below)
		return true
	return false


func _sweep_horizontally() -> bool:
	var next_cell = current_cell + Vector2i(horizontal_direction, 0)
	if _is_horizontal_cell_blocked(next_cell):
		horizontal_direction *= -1
		next_cell = current_cell + Vector2i(horizontal_direction, 0)
	if _is_horizontal_cell_blocked(next_cell):
		return false
	await _move_to_cell(next_cell)
	return true


func _move_to_cell(cell: Vector2i) -> void:
	var movement = create_tween()
	movement.set_trans(Tween.TRANS_LINEAR)
	movement.tween_property(self, "global_position", _cell_to_global(cell), MOVE_DURATION)
	await movement.finished
	current_cell = cell


func _cell_to_global(cell: Vector2i) -> Vector2:
	return tile_map_layer.to_global(tile_map_layer.map_to_local(cell))


func _cell_is_on_screen(cell: Vector2i) -> bool:
	var viewport_position = (
		tile_map_layer.get_global_transform_with_canvas()
		* tile_map_layer.map_to_local(cell)
	)
	var safe_viewport_rect = get_viewport().get_visible_rect().grow(-SCREEN_EDGE_MARGIN)
	return safe_viewport_rect.has_point(viewport_position)


func _on_area_entered(area: Area2D) -> void:
	if area is LaserShot:
		area.deactivate()
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
