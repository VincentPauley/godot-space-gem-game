extends AnimatedSprite2D


func _ready() -> void:
	play("default")
	_run_twinkle_cycle()


func _run_twinkle_cycle() -> void:
	while is_inside_tree():
		await get_tree().create_timer(randf_range(3.0, 10.0)).timeout
		if not is_inside_tree():
			return
		play("twinkle")
		await get_tree().create_timer(0.25).timeout
		if not is_inside_tree():
			return
		play("default")
