extends TextureButton

@onready var game = get_tree().get_root().get_node("Game")

@onready var clickmask_up = load("res://Assets/ClickMasks/diagonal_up_clickmask.bmp")
@onready var clickmask_down = load("res://Assets/ClickMasks/diagonal_down_clickmask.bmp")
@onready var clickmask_vertical = load("res://Assets/ClickMasks/vertical_connector_clickmask.bmp")
@onready var clickmask_horizontal = load("res://Assets/ClickMasks/horizontal_connector_clickmask.bmp")

@export var pos_start: Vector2i
@export var pos_end: Vector2i
@export var connector_type: String

var x_pos_start = pos_start[0]
var y_pos_start = pos_start[1]
var x_pos_end = pos_end[0]
var y_pos_end = pos_end[1]


var normal_texture:AtlasTexture
var pressed_texture:AtlasTexture
var disabled_texture:AtlasTexture
var offset: int = 240

signal connector_button_pressed(pos_start, pos_end)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initiate_textures()
	disabled = true
	connector_button_pressed.connect(game._on_connector_button_pressed)
	game.win.connect(_on_win)
	game.show_correct_connector.connect(_on_show_correct_connector)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _pressed() -> void:

	connector_button_pressed.emit(pos_start, pos_end)
	disabled = true
	if Global.SHOW_CORRECT_SOLUTION:
		set_self_modulate(Color(1, 1, 1, 0.5))

func _on_win():
	set_button_mask(0)
	
func _on_show_correct_connector(pos_start_i,pos_end_i):
	if pos_start==pos_start_i:
		if pos_end==pos_end_i:
			match connector_type:
				"Horizontal":
					disabled_texture = texture_disabled.duplicate() as AtlasTexture
					disabled_texture.region = Rect2(0,64+offset,32,32)
					set_texture_disabled(disabled_texture)
					set_self_modulate(Color(1, 1, 1, 0.5))
				"Vertical":
					disabled_texture = texture_disabled.duplicate() as AtlasTexture
					disabled_texture.region = Rect2(0,32+offset,32,32)
					set_texture_disabled(disabled_texture)
					set_self_modulate(Color(1, 1, 1, 0.5))
				"Diagonal":
					if (pos_start[1]-pos_end[1])/(pos_start[0]-pos_end[0]) == 1:
						# diagonal down
						disabled_texture = texture_disabled.duplicate() as AtlasTexture
						disabled_texture.region = Rect2(64,0+offset,96,96)
						set_texture_disabled(disabled_texture)
						set_self_modulate(Color(1, 1, 1, 0.5))
					elif (pos_start[1]-pos_end[1])/(pos_start[0]-pos_end[0]) == -1:
						# diagonal up
						disabled_texture = texture_disabled.duplicate() as AtlasTexture
						disabled_texture.region = Rect2(256,0+offset,96,96)
						set_texture_disabled(disabled_texture)
						set_self_modulate(Color(1, 1, 1, 0.5))
					

func initiate_textures():
	match connector_type:
		"Horizontal":
			normal_texture = texture_normal.duplicate() as AtlasTexture
			pressed_texture = texture_pressed.duplicate() as AtlasTexture
			normal_texture.region = Rect2(0,64,32,32)
			pressed_texture.region = Rect2(32,64,32,32)
			set_texture_normal(normal_texture)
			set_texture_pressed(pressed_texture)
			set("texture_click_mask",clickmask_horizontal)
		"Vertical":
			normal_texture = texture_normal.duplicate() as AtlasTexture
			pressed_texture = texture_pressed.duplicate() as AtlasTexture
			normal_texture.region = Rect2(0,32,32,32)
			pressed_texture.region = Rect2(32,32,32,32)
			set_texture_normal(normal_texture)
			set_texture_pressed(pressed_texture)
			set("texture_click_mask",clickmask_vertical)
		"Diagonal":
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
