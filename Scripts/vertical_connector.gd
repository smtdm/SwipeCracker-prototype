extends TextureButton

@onready var game = get_tree().get_root().get_node("Game")

var pos_start: Vector2i
var pos_end: Vector2i

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



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _pressed() -> void:

	connector_button_pressed.emit(pos_start, pos_end)
	disabled = true

func _on_win():
	set_button_mask(0)
