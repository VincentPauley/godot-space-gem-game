extends CanvasLayer

signal transition_finished

# NOTE: in order for this script to work it must be registered as an autoload
# in project settings > global

var _color_rect: ColorRect
var _tween: Tween
var _fade_duration: float = 0.4


func _ready() -> void:
	layer = 100 # draws above everything (Q: is this a property every node has?)
	process_mode = Node.PROCESS_MODE_ALWAYS # (Q: no idea what this is for)
	
	_color_rect = ColorRect.new()
	_color_rect.color = Color.BLACK
	_color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE # (Q:)
	_color_rect.modulate.a = 0.0  # (Q:)
	add_child(_color_rect)
	
func change_scene(path: String) -> void:
	_color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	await _fade(1.0) # fade to black
	
	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("Scene Change failed: %s", path)
		
	await get_tree().process_frame
	
	await _fade(0.0)
	
	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_finished.emit()

func _fade(target_alpha: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_color_rect, "modulate:a", target_alpha, _fade_duration)
	await _tween.finished
