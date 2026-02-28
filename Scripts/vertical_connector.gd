extends TextureButton

@onready var game = get_tree().get_root().get_node("Game")

var x_pos: int
var y_pos: int

signal connector_button_pressed(x_pos, y_pos)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	disabled = true
	connector_button_pressed.connect(game._on_connector_button_pressed)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	pass

func _pressed() -> void:

	connector_button_pressed.emit(x_pos, y_pos)
	disabled = true
