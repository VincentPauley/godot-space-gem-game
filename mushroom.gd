extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

const SHEET = preload("res://assets/mushrooms.png")
const FRAME_SIZE = Vector2(40, 40) # < hard-coded ref to how big an individual sprite is

var frames: Array[AtlasTexture] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# setup frames
	for i in range(6):
		#print(i)
		var atlas = AtlasTexture.new()
		atlas.atlas = SHEET
		
		var y_pos = 0
		
		if i > 2:
			y_pos = FRAME_SIZE.y
		
		var x_pos = (i % 3) * FRAME_SIZE.x
		
		atlas.region = Rect2(x_pos, y_pos,  FRAME_SIZE.x, FRAME_SIZE.y)
		frames.append(atlas)
		
	sprite.texture = frames[0]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
