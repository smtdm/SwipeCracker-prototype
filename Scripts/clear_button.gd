extends Button

@onready var game = get_tree().get_root().get_node("Game")

signal clear_button_pressed()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clear_button_pressed.connect(game._on_clear_button_pressed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _pressed() -> void:
	clear_button_pressed.emit()
	pass
	
func _on_win():
	text = "Reset?"
