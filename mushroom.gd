@tool
extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

const SHEET = preload("res://assets/mushrooms.png")
const FRAME_SIZE = Vector2(40, 40) # < hard-coded ref to how big an individual sprite is

var frames: Array[AtlasTexture] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if area is LaserShot:
		area.deactivate()
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
