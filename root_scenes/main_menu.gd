extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_start_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://node_2d.tscn")
	TransitionManager.change_scene("res://node_2d.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
