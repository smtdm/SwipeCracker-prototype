extends TextureButton

signal circle_button_pressed(x_pos, y_pos)

@onready var game = get_tree().get_root().get_node("Game")

var x_pos: int
var y_pos: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	circle_button_pressed.connect(game._on_circle_button_pressed)
	game.win.connect(_on_win)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	pass

func _pressed() -> void:
	circle_button_pressed.emit(x_pos,y_pos)


func _on_deselect_button():
	set_pressed(false)
	
func _on_win():
	set_button_mask(0)
