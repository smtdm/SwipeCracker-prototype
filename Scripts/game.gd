extends Node2D

@onready var game = get_tree().get_root().get_node("Game")
@onready var circle_buttons_node = game.get_node("Circle_buttons")
@onready var vertical_connectors_node = game.get_node("Vertical_connectors")
@onready var horizontal_connectors_node = game.get_node("Horizontal_connectors")

@onready var circle_button = load("res://Scenes/circle_button.tscn")
@onready var horizontal_connector = load("res://Scenes/horizontal_connector.tscn")
@onready var vertical_connector = load("res://Scenes/vertical_connector.tscn")

@onready var game_manager: Node = %GameManager

signal deselect_button

const WIDTH: int = 3
const HEIGHT: int = 3
const WEIGHT: float = 0.05 # determines the chance an edge will be generated

var last_pressed = Vector2i(-1,-1)

var connected_vertical_edges = Array()
var connected_horizontal_edges = Array()
var connected_nodes = Array()

var correct_vertical_edges = Array()
var correct_horizontal_edges = Array()
var correct_nodes = Array()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_game()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func load_game():
	for x_pos in range(WIDTH):
		for y_pos in range(HEIGHT):
			generate_circle_button(x_pos, y_pos)
			if x_pos<WIDTH-1:
				generate_horizontal_connector(Vector2i(x_pos,y_pos),Vector2i(x_pos+1,y_pos))
			if y_pos<HEIGHT-1:
				generate_vertical_connector(Vector2i(x_pos,y_pos),Vector2i(x_pos,y_pos+1))
	game_manager.update_label("edges", 0)
	game_manager.update_label("nodes", 0)
	generate_random_graph()
	

func generate_circle_button(x_pos, y_pos):
	var circle_button = circle_button.instantiate()
	circle_button.position = Vector2(x_pos*64, y_pos*64)
	circle_button.x_pos = int(x_pos)
	circle_button.y_pos = int(y_pos)
	circle_button.name = str("Circle_button",x_pos,",",y_pos)
	deselect_button.connect(circle_button._on_deselect_button)
	circle_buttons_node.add_child(circle_button)
	return circle_button
	
func generate_horizontal_connector(pos_start,pos_end):
	var horizontal_connector = horizontal_connector.instantiate()
	horizontal_connector.position = Vector2(pos_start[0]*64+32, pos_start[1]*64)
	horizontal_connector.pos_start = pos_start
	horizontal_connector.pos_end = pos_end
	horizontal_connector.name = str("Horizontal_connector",pos_start,"to",pos_end)
	horizontal_connectors_node.add_child(horizontal_connector)
	return horizontal_connector
		
func generate_vertical_connector(pos_start,pos_end):
	var vertical_connector = vertical_connector.instantiate()
	vertical_connector.position = Vector2(pos_start[0]*64, pos_start[1]*64+32)
	vertical_connector.pos_start = pos_start
	vertical_connector.pos_end = pos_end
	vertical_connector.name = str("Vertical_connector",pos_start,"to",pos_end)
	vertical_connectors_node.add_child(vertical_connector)
	return vertical_connector

func generate_random_graph(): # TODO Change to new coordiate system
	var rng = RandomNumberGenerator.new()
	var directions = ["left", "right", "up", "down"]
	var directions_weights = PackedFloat32Array([1, 1, 1, 1 ])
	
	var x_start_point = randi_range(0,WIDTH-1)
	var y_start_point = randi_range(0,HEIGHT-1)
	print("start point: ", x_start_point, "; ", y_start_point)
	
	var current_x = x_start_point
	var current_y = y_start_point
	
	var current_connection = Array()
	
	while randf() > WEIGHT:
		current_connection.clear()
		
		match directions[rng.rand_weighted(directions_weights)]:
			"left":
				if (current_x-1)<0:
					continue
				else:
					current_connection.append(Vector2i(current_x-1, current_y))
					current_connection.append(Vector2i(current_x, current_y))
					#current_connection.sort()
					if !correct_horizontal_edges.has(current_connection):
						correct_horizontal_edges.append([current_connection[0],current_connection[1]])
						current_x -= 1
					else:
						continue
			"right":
				if (current_x+1)>WIDTH-1:
					continue
				else:
					current_connection.append(Vector2i(current_x, current_y))
					current_connection.append(Vector2i(current_x+1, current_y))
					#current_connection.sort()
					if !correct_horizontal_edges.has(current_connection):
						correct_horizontal_edges.append([current_connection[0],current_connection[1]])
						current_x += 1
					else:
						continue
			"up":
				if (current_y-1)<0:
					continue
				else:
					current_connection.append(Vector2i(current_x, current_y-1))
					current_connection.append(Vector2i(current_x, current_y))
					#current_connection.sort()
					if !correct_vertical_edges.has(current_connection):
						correct_vertical_edges.append([current_connection[0],current_connection[1]])
						current_y -= 1
					else:
						continue
			"down":
				if (current_y+1)>HEIGHT-1:
					continue
				else:
					current_connection.append(Vector2i(current_x, current_y))
					current_connection.append(Vector2i(current_x, current_y+1))
					#current_connection.sort()
					if !correct_vertical_edges.has(current_connection):
						correct_vertical_edges.append([current_connection[0],current_connection[1]])
						current_y += 1
					else:
						continue		
	print("correct horizontal edges: ", correct_horizontal_edges)
	print("correct vertical edges: ", correct_vertical_edges)
	correct_horizontal_edges.sort()
	correct_vertical_edges.sort()
	
	##generate correct nodes array
	#for i_vertical in correct_vertical_edges:
		#if !correct_nodes.has(Vector2(i_vertical[0],i_vertical[1]-1)):
			#correct_nodes.append(Vector2(i_vertical[0],i_vertical[1]-1))
		#if !correct_nodes.has(Vector2(i_vertical[0],i_vertical[1]+1)):
			#correct_nodes.append(Vector2(i_vertical[0],i_vertical[1]+1))
	#for i_horizontal in correct_horizontal_edges:
		#if !correct_nodes.has(Vector2(i_horizontal[0]-1,i_horizontal[1])):
			#correct_nodes.append(Vector2(i_horizontal[0]-1,i_horizontal[1]))
		#if !correct_nodes.has(Vector2(i_horizontal[0]+1,i_horizontal[1])):
			#correct_nodes.append(Vector2(i_horizontal[0]+1,i_horizontal[1]))
	#correct_nodes.sort()
	print("verticals: ", correct_vertical_edges)
	print("horizontals: ", correct_horizontal_edges)
	print("nodes: ", correct_nodes)
	
func _on_circle_button_pressed(x_pos, y_pos):
	var now_pressed = Vector2i(x_pos,y_pos)
	
	if now_pressed == last_pressed:
		# same button is clicked -> disable selection
		last_pressed = Vector2i(-1,-1)
		# NOG IETS NODIG?
	elif last_pressed == Vector2i(-1,-1):
		# no button pressed yet -> set button as first one
		last_pressed = now_pressed
	else:
		# second button is pressed and different from first one
		# -> make connection
		var min_x = int(min(last_pressed[0],now_pressed[0]))
		var min_y = int(min(last_pressed[1],now_pressed[1]))
		
		var nodes_pressed_array = Array()
		nodes_pressed_array.append(now_pressed)
		nodes_pressed_array.append(last_pressed)
		nodes_pressed_array.sort()
		
		if abs(last_pressed - now_pressed) == Vector2i(0,1):
			# vertical pressed
			var current_connector = vertical_connectors_node.get_node(str("Vertical_connector",nodes_pressed_array[0],"to",nodes_pressed_array[1]).replace(".","_"))
			current_connector.disabled = false
			if !connected_vertical_edges.has(nodes_pressed_array):
				connected_vertical_edges.append(nodes_pressed_array)
				connected_nodes.append(now_pressed)
				connected_nodes.append(last_pressed)
			deselect_button.emit()
			last_pressed = Vector2i(-1,-1)
		if abs(last_pressed - now_pressed) == Vector2i(1,0):
			# horizontal pressed
			var current_connector = horizontal_connectors_node.get_node(str("Horizontal_connector",nodes_pressed_array[0],"to",nodes_pressed_array[1]).replace(".","_"))
			current_connector.disabled = false
			# check if connection is in the array, else add it and its nodes to the connected arrays
			if !connected_horizontal_edges.has(nodes_pressed_array):
				connected_horizontal_edges.append(nodes_pressed_array)
				connected_nodes.append(now_pressed)
				connected_nodes.append(last_pressed)
			deselect_button.emit()
			last_pressed = Vector2i(-1,-1)
			
		#TODO diagonal and slanted
		
		else:
			deselect_button.emit()
			last_pressed = Vector2i(-1,-1)
		pass
	print(x_pos,", ", y_pos)
	print("vertical edges: ",connected_vertical_edges)
	print("horizontal edges: ",connected_horizontal_edges)
	pass
		
func _on_connector_button_pressed(pos_start, pos_end):
	var nodes_connected_arr = Array()
	nodes_connected_arr.append(pos_start)
	nodes_connected_arr.append(pos_end)
	
	if connected_horizontal_edges.has(nodes_connected_arr):
		connected_horizontal_edges.erase(nodes_connected_arr)
		connected_nodes.erase(pos_start)
		connected_nodes.erase(pos_end)
	if connected_vertical_edges.has(nodes_connected_arr):
		connected_vertical_edges.erase(nodes_connected_arr)
		connected_nodes.erase(pos_start)
		connected_nodes.erase(pos_end)

func _on_check_button_pressed():
	var correct_edges = check_connectors()
	var correct_nodes = check_nodes()
	game_manager.update_label("correct edges", correct_edges)
	game_manager.update_label("correct nodes", correct_nodes)
	# check win condition
	if len(connected_horizontal_edges)+len(correct_vertical_edges) == correct_edges:
		print("you won!")

func check_connectors():
	connected_horizontal_edges.sort()
	connected_vertical_edges.sort()
	var vertical_edges_correct_count = 0
	var horizontal_edges_correct_count = 0
	
	for vertical_i in connected_vertical_edges:
		if correct_vertical_edges.has(vertical_i):
			vertical_edges_correct_count += 1
	for horizontal_i in connected_horizontal_edges:
		if correct_horizontal_edges.has(horizontal_i):
			horizontal_edges_correct_count += 1
			
	var correct_edges = vertical_edges_correct_count+horizontal_edges_correct_count
	return correct_edges

func check_nodes():
	connected_nodes.sort()
	var nodes_correct_count = 0
	
	for nodes_i in correct_nodes:
		if connected_nodes.has(nodes_i):
			nodes_correct_count +=1
	return nodes_correct_count
