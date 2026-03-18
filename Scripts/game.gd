extends Node2D

@onready var game = get_tree().get_root().get_node("Game")
@onready var circle_buttons_node = game.get_node("Circle_buttons")
@onready var vertical_connectors_node = game.get_node("Vertical_connectors")
@onready var horizontal_connectors_node = game.get_node("Horizontal_connectors")
@onready var diagonal_connectors_node = game.get_node("Diagonal_connectors")

@onready var check_button = game.get_node("CheckButton")
@onready var clear_button = game.get_node("ClearButton")

@onready var circle_button = load("res://Scenes/circle_button.tscn")
@onready var connector = load("res://Scenes/connector.tscn")

@onready var game_manager: Node = %GameManager

signal deselect_button
signal win
signal show_correct_connector
signal disable_connector

const WIDTH: int = 3
const HEIGHT: int = 3
const WEIGHT: float = 0.05 # determines the chance an edge will be generated

var game_won: bool = false

var last_pressed = Vector2i(-1,-1)

var connected_vertical_edges = Array()
var connected_horizontal_edges = Array()
var connected_diagonal_edges = Array()
var connected_nodes = Array()

var correct_vertical_edges = Array()
var correct_horizontal_edges = Array()
var correct_diagonal_edges = Array()
var correct_nodes = Array()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_game()
	if Global.SHOW_CORRECT_SOLUTION:
		show_correct_connectors()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## initialises the game. Should only be called once during the setup. 
func load_game():
	
	for x_pos in range(WIDTH):
		for y_pos in range(HEIGHT):
			# generate nodes
			generate_circle_button(x_pos, y_pos)
			# Generate edges
			if x_pos<WIDTH-1:
				generate_connector(Vector2i(x_pos,y_pos),Vector2i(x_pos+1,y_pos),"Horizontal")
				if y_pos<HEIGHT-1:
					generate_connector(Vector2i(x_pos,y_pos),Vector2i(x_pos+1,y_pos+1),"Diagonal")
					generate_connector(Vector2i(x_pos,y_pos+1),Vector2i(x_pos+1,y_pos),"Diagonal")
			if y_pos<HEIGHT-1:
				generate_connector(Vector2i(x_pos,y_pos),Vector2i(x_pos,y_pos+1),"Vertical")
	# update labels 
	game_manager.update_label("correct edges", 0)
	game_manager.update_label("correct nodes", 0)
	
	# connect buttons to win signal
	win.connect(check_button._on_win)
	win.connect(clear_button._on_win)
	
	# generate correct solution
	generate_random_graph()
	
## generates the clickable nodes on a grid starting from the top left. 
func generate_circle_button(x_pos, y_pos):
	var circle_button = circle_button.instantiate()
	circle_button.position = Vector2(x_pos*64, y_pos*64)
	circle_button.x_pos = int(x_pos)
	circle_button.y_pos = int(y_pos)
	circle_button.name = str("Circle_button",x_pos,",",y_pos)
	deselect_button.connect(circle_button._on_deselect_button)
	circle_buttons_node.add_child(circle_button) # add to a general node for better organisation
	return circle_button

## Generates the connectors between the nodes. 
## Uses the starting and end position (the position of two nodes) to check the type of connector.
func generate_connector(pos_start,pos_end,type):
	var connector = connector.instantiate()
	connector.pos_start = pos_start
	connector.pos_end = pos_end
	connector.connector_type = type
	connector.name = str(type,"_connector",pos_start,"to",pos_end)
	match type:
		"Horizontal":
			connector.position = Vector2(pos_start[0]*64+32, pos_start[1]*64)
			horizontal_connectors_node.add_child(connector)
		"Vertical":
			connector.position = Vector2(pos_start[0]*64, pos_start[1]*64+32)
			vertical_connectors_node.add_child(connector)
		"Diagonal":
			if (pos_start[1]-pos_end[1])/(pos_start[0]-pos_end[0]) == 1:
				connector.position = Vector2(pos_start[0]*64, pos_start[1]*64) 
			elif (pos_start[1]-pos_end[1])/(pos_start[0]-pos_end[0]) == -1:
				connector.position = Vector2(pos_start[0]*64, pos_start[1]*64-64) 
			diagonal_connectors_node.add_child(connector)
	return connector

## Shows all correct connections. Should only be used as a debug tool
func show_correct_connectors():
	for connector in correct_horizontal_edges:
		show_correct_connector.emit(connector[0],connector[1])
	for connector in correct_vertical_edges:
		show_correct_connector.emit(connector[0],connector[1])
	for connector in correct_diagonal_edges:
		show_correct_connector.emit(connector[0],connector[1])
		
### Generates a semi-random graph consisting of a single line. 
### The graph can be drawn without backtracking or lifting the pen
### Graph contains  only horizontal and vertical edges
#func generate_random_graph_level1(): 
	#var rng = RandomNumberGenerator.new()
	#var directions = ["left", "right", "up", "down"]
	#var directions_weights = PackedFloat32Array([1, 1, 1, 1 ])
	#
	#var x_start_point = randi_range(0,WIDTH-1)
	#var y_start_point = randi_range(0,HEIGHT-1)
	#print("start point: ", x_start_point, "; ", y_start_point)
	#
	#var current_x = x_start_point
	#var current_y = y_start_point
	#
	#var current_connection = Array()
	#
	#while randf() > WEIGHT:
		#current_connection.clear()
		#
		##Add new edge
		#match directions[rng.rand_weighted(directions_weights)]:
			#"left":
				#if (current_x-1)<0:
					#continue
				#else:
					#current_connection.append(Vector2i(current_x-1, current_y))
					#current_connection.append(Vector2i(current_x, current_y))
					##current_connection.sort()
					#if !correct_horizontal_edges.has(current_connection):
						#correct_horizontal_edges.append([current_connection[0],current_connection[1]])
						#current_x -= 1
#
			#"right":
				#if (current_x+1)>WIDTH-1:
					#continue
				#else:
					#current_connection.append(Vector2i(current_x, current_y))
					#current_connection.append(Vector2i(current_x+1, current_y))
					##current_connection.sort()
					#if !correct_horizontal_edges.has(current_connection):
						#correct_horizontal_edges.append([current_connection[0],current_connection[1]])
						#current_x += 1
#
			#"up":
				#if (current_y-1)<0:
					#continue
				#else:
					#current_connection.append(Vector2i(current_x, current_y-1))
					#current_connection.append(Vector2i(current_x, current_y))
					##current_connection.sort()
					#if !correct_vertical_edges.has(current_connection):
						#correct_vertical_edges.append([current_connection[0],current_connection[1]])
						#current_y -= 1
#
			#"down":
				#if (current_y+1)>HEIGHT-1:
					#continue
				#else:
					#current_connection.append(Vector2i(current_x, current_y))
					#current_connection.append(Vector2i(current_x, current_y+1))
					##current_connection.sort()
					#if !correct_vertical_edges.has(current_connection):
						#correct_vertical_edges.append([current_connection[0],current_connection[1]])
						#current_y += 1
		#
		## generate correct nodes array
		#if !correct_nodes.has(current_connection[0]):
			#correct_nodes.append(current_connection[0])
		#if !correct_nodes.has(current_connection[1]):
			#correct_nodes.append(current_connection[1])
		#
	#correct_horizontal_edges.sort()
	#correct_vertical_edges.sort()
	#correct_nodes.sort()
#
	#print("verticals: ", correct_vertical_edges)
	#print("horizontals: ", correct_horizontal_edges)
	#print("nodes: ", correct_nodes)

## Generates a semi-random graph consisting of a single line. 
## The graph can be drawn without backtracking or lifting the pen
## The graph contains horizontal, vertical and/or diagonal edges
## tweak the weights to gain a different experience, a weight of 0 means that type of connection will not be used
func generate_random_graph():
	var rng = RandomNumberGenerator.new()
	var directions = ["left", "right", "up", "down", "right_down", "right_up", "left_down", "left_up"]
	var level1_weights = PackedFloat32Array([1, 1, 1, 1, 0, 0, 0, 0]) # only left, right, up and down
	var level2_weights =  PackedFloat32Array([1, 1, 1, 1, 1, 1, 1, 1])
	var level3_weights =  PackedFloat32Array([0, 0, 0, 0, 1, 1, 1, 1]) # only diagonals
	
	var max_connections = 7 # maximum number of connections (edges)
	
	var directions_weights = level3_weights
	
	var x_start_point = randi_range(0,WIDTH-1)
	var y_start_point = randi_range(0,HEIGHT-1)
	print("start point: ", x_start_point, "; ", y_start_point)
	
	var current_x = x_start_point
	var current_y = y_start_point
	
	var current_connection = Array()
	var number_of_connections: int = 0
	
	var x: int = 0
	#while randf() > WEIGHT:
	while number_of_connections < max_connections:
		# failsafe, if the generator gets stuck it will end eventually
		x += 1
		print(x)
		if x> max_connections**2:
			break

		current_connection.clear()
		
		# Add new edge, checks first if the connection will not be out of bounds, then checks if the connection already has been made.
		# If not, adds the connection and moves to the new node
		match directions[rng.rand_weighted(directions_weights)]:
			"left":
				if (current_x-1)<0:
					continue
				else:
					current_connection.append(Vector2i(current_x-1, current_y))
					current_connection.append(Vector2i(current_x, current_y))
					if !correct_horizontal_edges.has(current_connection):
						correct_horizontal_edges.append([current_connection[0],current_connection[1]])
						current_x -= 1
						number_of_connections += 1
						print("left")
			
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
						number_of_connections += 1
						print("right")
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
						number_of_connections += 1
						print("up")
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
						number_of_connections += 1
						print("down")
			"right_down":
				if (current_x+1)>WIDTH-1:
					continue
				if (current_y+1)>HEIGHT-1:
					continue
				else:
					current_connection.append(Vector2i(current_x, current_y))
					current_connection.append(Vector2i(current_x+1, current_y+1))
					if !correct_diagonal_edges.has(current_connection):
						correct_diagonal_edges.append([current_connection[0],current_connection[1]])
						current_y += 1
						current_x += 1
						number_of_connections += 1
						print("right_down")
			"right_up":
				if (current_x+1)>WIDTH-1:
					continue
				if (current_y-1)<0:
					continue
				else:
					current_connection.append(Vector2i(current_x, current_y))
					current_connection.append(Vector2i(current_x+1, current_y-1))
					if !correct_diagonal_edges.has(current_connection):
						correct_diagonal_edges.append([current_connection[0],current_connection[1]])
						current_y -= 1
						current_x += 1
						number_of_connections += 1
						print("right_up")
			"left_down":
				if (current_x-1)<0:
					continue
				if (current_y+1)>HEIGHT-1:
					continue
				else:
					current_connection.append(Vector2i(current_x-1, current_y+1))
					current_connection.append(Vector2i(current_x, current_y))
					if !correct_diagonal_edges.has(current_connection):
						correct_diagonal_edges.append([current_connection[0],current_connection[1]])
						current_y += 1
						current_x -= 1
						number_of_connections += 1
						print("left_down")
					
			"left_up":
				if (current_y-1)<0:
					continue
				if (current_x-1)<0:
					continue
				else:
					current_connection.append(Vector2i(current_x-1, current_y-1))
					current_connection.append(Vector2i(current_x, current_y))
					if !correct_diagonal_edges.has(current_connection):
						correct_diagonal_edges.append([current_connection[0],current_connection[1]])
						current_y -= 1
						current_x -= 1
						number_of_connections += 1
						print("left_up")
		# generate correct nodes array
		if !correct_nodes.has(current_connection[0]):
			correct_nodes.append(current_connection[0])
		if !correct_nodes.has(current_connection[1]):
			correct_nodes.append(current_connection[1])
		
	correct_horizontal_edges.sort()
	correct_vertical_edges.sort()
	correct_nodes.sort()

	print("verticals: ", correct_vertical_edges)
	print("horizontals: ", correct_horizontal_edges)
	print("diagonals: ", correct_diagonal_edges)
	print("nodes: ", correct_nodes)
	
func check_connectors():
	connected_horizontal_edges.sort()
	connected_vertical_edges.sort()
	var vertical_edges_correct_count = 0
	var horizontal_edges_correct_count = 0
	var diagonal_edges_correct_count = 0
	
	for vertical_i in connected_vertical_edges:
		if correct_vertical_edges.has(vertical_i):
			vertical_edges_correct_count += 1
	for horizontal_i in connected_horizontal_edges:
		if correct_horizontal_edges.has(horizontal_i):
			horizontal_edges_correct_count += 1
	for diagonal_i in connected_diagonal_edges:
		if correct_diagonal_edges.has(diagonal_i):
			diagonal_edges_correct_count += 1
					
	var correct_edges = vertical_edges_correct_count+horizontal_edges_correct_count+diagonal_edges_correct_count
	return correct_edges

func check_nodes():
	connected_nodes.sort()
	var nodes_correct_count = 0
	
	for nodes_i in correct_nodes:
		if connected_nodes.has(nodes_i):
			nodes_correct_count +=1
	return nodes_correct_count
	
func reset_game():
	get_tree().reload_current_scene()
	
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
			current_connector.set_self_modulate(Color(1, 1, 1, 1))
			if !connected_vertical_edges.has(nodes_pressed_array):
				connected_vertical_edges.append(nodes_pressed_array)
				connected_nodes.append(now_pressed)
				connected_nodes.append(last_pressed)
			deselect_button.emit()
			last_pressed = Vector2i(-1,-1)
		elif abs(last_pressed - now_pressed) == Vector2i(1,0):
			# horizontal pressed
			var current_connector = horizontal_connectors_node.get_node(str("Horizontal_connector",nodes_pressed_array[0],"to",nodes_pressed_array[1]).replace(".","_"))
			current_connector.disabled = false
			current_connector.set_self_modulate(Color(1, 1, 1, 1))
			# check if connection is in the array, else add it and its nodes to the connected arrays
			if !connected_horizontal_edges.has(nodes_pressed_array):
				connected_horizontal_edges.append(nodes_pressed_array)
				connected_nodes.append(now_pressed)
				connected_nodes.append(last_pressed)
			deselect_button.emit()
			last_pressed = Vector2i(-1,-1)
		
		
		elif ((last_pressed[1]-now_pressed[1])/(last_pressed[0]-now_pressed[0]) == -1) or ((last_pressed[1]-now_pressed[1])/(last_pressed[0]-now_pressed[0]) == 1):
			#diagonal pressed
			var current_connector = diagonal_connectors_node.get_node(str("Diagonal_connector",nodes_pressed_array[0],"to",nodes_pressed_array[1]).replace(".","_"))
			current_connector.disabled = false
			current_connector.set_self_modulate(Color(1, 1, 1, 1))
			# check if connection is in the array, else add it and its nodes to the connected arrays
			if !connected_diagonal_edges.has(nodes_pressed_array):
				connected_diagonal_edges.append(nodes_pressed_array)
				connected_nodes.append(now_pressed)
				connected_nodes.append(last_pressed)
			deselect_button.emit()
			last_pressed = Vector2i(-1,-1)
		#TODO slanted
		
		else:
			deselect_button.emit()
			last_pressed = Vector2i(-1,-1)

		
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
	if connected_diagonal_edges.has(nodes_connected_arr):
		connected_diagonal_edges.erase(nodes_connected_arr)
		connected_nodes.erase(pos_start)
		connected_nodes.erase(pos_end)
		
func _on_check_button_pressed():
	var correct_connected_edges = check_connectors()
	var correct_nodes = check_nodes()
	game_manager.update_label("correct edges", correct_connected_edges)
	game_manager.update_label("correct nodes", correct_nodes)
	# check win condition
	if len(connected_horizontal_edges)+len(connected_vertical_edges)+len(connected_diagonal_edges) == correct_connected_edges:
		win.emit()
		game_won = true

func _on_clear_button_pressed():
	if game_won:
		reset_game()
	disable_connector.emit()
	connected_horizontal_edges.clear()
	connected_vertical_edges.clear()
	connected_diagonal_edges.clear()
	connected_nodes.clear()
	
