extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	TransitionManager.change_scene("res://root_scenes/main_menu.tscn")
