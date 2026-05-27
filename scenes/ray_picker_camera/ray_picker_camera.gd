extends Camera3D

@export var spike_trap_avail: PackedScene
@export var gridmap: GridMap
@export var trap_manager: Node3D

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var ui: MarginContainer = $"../UI"

var trap_cost := 20 #Get this from the trap selected from UI
var ray_extend := 100.0 #Distance for Raycast to reach level
var selected_Trap :Object
var mouse_position_3d
var camera_moving_pos := false
var camera_moving_zoom := false
var camera_eps := .001
var camera_moving_to :Vector3
var camera_size_to :float
var zoom_value := 3.0
var zoom_end_value: float

var Layer_pos := [Vector3(10,22.5,10),Vector3(2.5,-14.5,2.5)]
var Layer_size := [11.0,16.0]

func _ready() -> void:
	ui.trap_select.connect(select_trap)
	position = Layer_pos[0]
	size = Layer_size[0]

func _process(delta: float) -> void:
	if Input.is_anything_pressed():
		check_cancel_select()
		check_change_layer()
	if camera_moving_pos || camera_moving_zoom:
		move_camera()
	
	mouse_raycast()
	if selected_Trap:
		move_selected_trap_holder()
	
	if ray_cast_3d.is_colliding():
		var collider = ray_cast_3d.get_collider()
		if collider is GridMap:
			var collision_point = ray_cast_3d.get_collision_point()
			var cell = gridmap.local_to_map(collision_point)
			if gridmap.get_cell_item(cell) == 0:
				Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
				if Input.is_action_pressed("click"):  #&& trap selected from UI.
					if selected_Trap:
						gridmap.set_cell_item(cell, 1)
						var tile_position = gridmap.map_to_local(cell)
						trap_manager.build_trap(selected_Trap,tile_position)
						end_select_trap_check()
			else:
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom("in")
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom("out")

func check_cancel_select() -> void:
	if Input.is_action_just_pressed("CancelSelection"):
			end_select_trap_check()

func check_change_layer() -> void:
	if Input.is_action_just_pressed("Layer_1"):
		camera_moving_zoom = false
		camera_moving_pos = true
		camera_moving_to = Layer_pos[0]
		camera_size_to = Layer_size[0]
	elif Input.is_action_just_pressed("Layer_2"):
		camera_moving_zoom = false
		camera_moving_pos = true
		camera_moving_to = Layer_pos[1]
		camera_size_to = Layer_size[1]
	elif Input.is_action_just_pressed("Layer_3"):
		pass
	elif Input.is_action_just_pressed("Layer_4"):
		pass
	elif Input.is_action_just_pressed("Layer_5"):
		pass

func move_camera() -> void:
	if camera_moving_pos:
		position = position.lerp(camera_moving_to,.1)
		if !camera_moving_zoom:
			size = lerp(size,camera_size_to,.2)
		if position.is_equal_approx(camera_moving_to):
			camera_moving_pos = false
	if camera_moving_zoom:
		size = lerp(size,zoom_end_value,.1)
		if is_equal_approx(size, zoom_end_value):
			camera_moving_zoom = false
			print(size)

var size_min := 3.0
var size_max := 20.0

func zoom(direction:String) -> void:
	camera_moving_zoom = true
	if direction == "in":
		zoom_end_value = max(size - zoom_value, size_min)
	elif direction == "out":
		zoom_end_value = min(size + zoom_value, size_max)
	else:
		print("error when zooming")

func select_trap(new_trap: Object) -> void:
	selected_Trap = new_trap
	if !gridmap.get_children():
		add_trap_placement_options()
		create_selected_trap_holder()

func create_selected_trap_holder() ->void:
	mouse_position_3d = project_position (get_viewport().get_mouse_position(), 1)
	var new_spike_holder = selected_Trap.instantiate()
	new_spike_holder.position = mouse_position_3d
	new_spike_holder.holder = true
	gridmap.add_child(new_spike_holder)

func move_selected_trap_holder() ->void:
	var selected_trap_holder = gridmap.get_children()
	#print(selected_Trap)    #Figure out how to check if selected_trap is the same name as the holder.
	for i in selected_trap_holder:
		if i.name == "SpikeTrap":
			i.position = project_position(get_viewport().get_mouse_position(), 1)

func add_trap_placement_options() -> void:
	var gridmap_list = gridmap.get_used_cells_by_item(0)  #Item 0 is CavePath
	if selected_Trap:
		for i in gridmap_list:
			var new_spike_avail_spot = spike_trap_avail.instantiate()
			new_spike_avail_spot.position = gridmap.map_to_local(i)
			gridmap.add_child(new_spike_avail_spot)

func remove_trap_placement_options() ->void:
	for i in gridmap.get_children():
		gridmap.remove_child(i)

func end_select_trap_check() -> void:
	selected_Trap = null
	remove_trap_placement_options()

func mouse_raycast() -> void:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	mouse_position_3d = project_position (mouse_position, 0)
	ray_cast_3d.global_position = mouse_position_3d
	ray_cast_3d.target_position = project_local_ray_normal(mouse_position) * ray_extend
	ray_cast_3d.force_raycast_update()
