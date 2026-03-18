extends TextureButton

@onready var game = get_tree().get_root().get_node("Game")
@onready var clickmask_up = load("res://Assets/ClickMasks/diagonal_up_clickmask.bmp")
@onready var clickmask_down = load("res://Assets/ClickMasks/diagonal_down_clickmask.bmp")

var pos_start: Vector2i
var pos_end: Vector2i

var normal_texture:AtlasTexture
var pressed_texture:AtlasTexture

var x_pos_start = pos_start[0]
var y_pos_start = pos_start[1]
var x_pos_end = pos_end[0]
var y_pos_end = pos_end[1]

signal connector_button_pressed(pos_start, pos_end)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	disabled = true
	connector_button_pressed.connect(game._on_connector_button_pressed)
	game.win.connect(_on_win)

	if (pos_start[1]-pos_end[1])/(pos_start[0]-pos_end[0]) == 1:
		# diagonal down
		normal_texture = texture_normal.duplicate() as AtlasTexture
		pressed_texture = texture_pressed.duplicate() as AtlasTexture
		normal_texture.region = Rect2(64,0,96,96)
		pressed_texture.region = Rect2(160,0,96,96)
		set_texture_normal(normal_texture)
		set_texture_pressed(pressed_texture)
		set("texture_click_mask",clickmask_down)
		
	elif (pos_start[1]-pos_end[1])/(pos_start[0]-pos_end[0]) == -1:
		# diagonal up
		normal_texture = texture_normal.duplicate() as AtlasTexture
		pressed_texture = texture_pressed.duplicate() as AtlasTexture
		normal_texture.region = Rect2(256,0,96,96)
		pressed_texture.region = Rect2(352,0,96,96)
		set_texture_normal(normal_texture)
		set_texture_pressed(pressed_texture)
		set("texture_click_mask",clickmask_up)
		
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	pass

func _pressed() -> void:

	connector_button_pressed.emit(pos_start, pos_end)
	disabled = true
	
func _on_win():
	set_button_mask(0)
