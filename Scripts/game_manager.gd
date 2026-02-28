extends Node

var value = 0

@onready var correct_edges_label: Label = $CorrectEdgesLabel
@onready var correct_nodes_label: Label = $CorrectNodesLabel


func update_label(label, value):
	match label:
		"correct edges":
			correct_edges_label.text = "Correct Edges: " + str(value) + "  "
		"correct nodes":
			correct_nodes_label.text = "Correct Nodes: " + str(value) + "  "
