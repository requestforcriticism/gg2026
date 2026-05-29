extends Camera3D

@export var spike_trap_avail: PackedScene
@export var trap_ability_manager: Node3D
@export var single_point: PackedScene
@export var layer_nodes : Array[Node3D]

@onready var gridmap = get_tree().get_first_node_in_group("gridmap")
@onready var level: Node3D = $".."
@onready var ray_cast_3d: RayCast3D = $RayCast3D

@onready var ui: MarginContainer = $"../UI"

var trap_cost := 20 #Get this from the trap selected from UI
var ray_extend := 100.0 #Distance for Raycast to reach level
var selected_Trap :Object
var selected_Trap_example :Object
var selected_Ability :Object
var selected_Ability_example :Object
var mouse_position_3d
var camera_on_layer := 1
var camera_moving_pos := false
var camera_moving_zoom := false
var camera_eps := .001
var camera_moving_to :Vector3
var camera_size_to :float
var camera_move_speed := 10.0
										#[min_x,max_x,min_z,max_z]
var camera_strafe_values :Array[Array] = [[6.0,14.0,6.0,14.0]
										,[-3.5,8.5,-3.5,8.5]]
var size_min := 3.0
var size_max := 20.0
var zoom_value := 3.0
var zoom_end_value: float

var mask_reset = 0
var mask_Traps = 1
var mask_Ability = 5

var Layer_pos := [Vector3(10,22.5,10),Vector3(2.5,-14.5,2.5)]
var Layer_size := [11.0,16.0]

func _ready() -> void:
	ui.trap_select.connect(select_trap)
	ui.ability_select.connect(select_ability)
	position = Layer_pos[0]
	size = Layer_size[0]

func _process(delta: float) -> void:
	if camera_moving_pos || camera_moving_zoom:
		move_camera()
	
	strafe_camera(delta)
	
	mouse_raycast()
	if selected_Trap || selected_Ability:
		move_selected_trap_ability_holder()
	
	if ray_cast_3d.is_colliding():
		var collider = ray_cast_3d.get_collider()
		if collider is GridMap:
			gridmap_collision()
		elif collider is CSGPolygon3D:
			csgpoly3d_collision(collider)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom("in")
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom("out")
		elif Input.is_action_just_pressed("CancelSelection"):
			check_cancel_select()
	elif event is InputEventKey:
		check_cancel_select()
		check_change_layer()

func csgpoly3d_collision(collider) -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	if Input.is_action_pressed("click"):  #&& trap selected from UI.
		if selected_Ability:
			var collision_point = ray_cast_3d.get_collision_point()
			var local_pos = collider.get_parent().to_local(collision_point)
			var Path3Doffset = collider.get_parent().curve.get_closest_offset(local_pos)
			trap_ability_manager.activate_ability(selected_Ability,Path3Doffset,collider.get_parent())
			print(collider.get_parent())
			end_select_trap_ability_check()

func gridmap_collision() -> void:
	var collision_point = ray_cast_3d.get_collision_point()
	var cell = gridmap.local_to_map(collision_point)
	if gridmap.get_cell_item(cell) == 0:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		if Input.is_action_pressed("click"):  #&& trap selected from UI.
			if selected_Trap:
				var tile_position = gridmap.map_to_local(cell)
				trap_ability_manager.build_trap(selected_Trap,tile_position,cell)
				end_select_trap_ability_check()
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func check_cancel_select() -> void:
	if Input.is_action_just_pressed("CancelSelection"):
			end_select_trap_ability_check()

func check_change_layer() -> void:
	if Input.is_action_just_pressed("Layer_1"):
		camera_on_layer = 1
		change_layer_stuff()
	elif level.layer_unlocked >=2 && Input.is_action_just_pressed("Layer_2"):
		camera_on_layer = 2
		change_layer_stuff()
	elif level.layer_unlocked >=3 && Input.is_action_just_pressed("Layer_3"):
		pass
	elif level.layer_unlocked >=4 && Input.is_action_just_pressed("Layer_4"):
		pass
	elif Input.is_action_just_pressed("Layer_5"):
		pass

func change_layer_stuff() -> void:
	camera_moving_zoom = false
	camera_moving_pos = true
	camera_moving_to = Layer_pos[camera_on_layer-1]
	camera_size_to = Layer_size[camera_on_layer-1]
	end_select_trap_ability_check()

func move_camera() -> void:
	if camera_moving_pos:
		position = position.lerp(camera_moving_to,.1)
		if !camera_moving_zoom:
			size = lerp(size,camera_size_to,.2)
		elif position.is_equal_approx(camera_moving_to):
			camera_moving_pos = false
	if camera_moving_zoom:
		size = lerp(size,zoom_end_value,.1)
		if is_equal_approx(size, zoom_end_value):
			camera_moving_zoom = false

func strafe_camera(delta) ->void:
	camera_move_speed = max(5,20/size)
	var input_dir: Vector2 = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	var direction: Vector3 = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, PI/4).normalized()
	if direction != Vector3.ZERO:
		camera_moving_pos = false
		global_translate(direction * camera_move_speed * delta)
		global_position.x = clamp(global_position.x, camera_strafe_values[camera_on_layer-1][0], camera_strafe_values[camera_on_layer-1][1])
		global_position.z = clamp(global_position.z, camera_strafe_values[camera_on_layer-1][2], camera_strafe_values[camera_on_layer-1][3])

func zoom(direction:String) -> void:
	camera_moving_zoom = true
	if direction == "in":
		zoom_end_value = max(size - zoom_value, size_min)
	elif direction == "out":
		zoom_end_value = min(size + zoom_value, size_max)
	else:
		print("error when zooming")

func select_ability(new_ability: Object, new_ability_example: Object) -> void:
	end_select_trap_ability_check()
	ray_cast_3d.set_collision_mask_value(mask_Ability,true)
	selected_Ability = new_ability
	selected_Ability_example = new_ability_example
	add_abilty_placement_options()
	create_selected_ability_holder()

func select_trap(new_trap: Object,new_trap_example: Object) -> void:
	end_select_trap_ability_check()
	ray_cast_3d.set_collision_mask_value(mask_Traps,true)
	selected_Trap = new_trap
	selected_Trap_example = new_trap_example
	create_selected_trap_holder()
	add_trap_placement_options()

@onready var single_point_path_3d: Path3D = $"../GridMap/SinglePointPath3D"


func create_selected_ability_holder() ->void:
	var new_ability_holder = selected_Ability_example.instantiate()
	new_ability_holder.holder = true
	new_ability_holder.speed = 0.0
	new_ability_holder.scale = Vector3(.75,.75,.75)
	single_point_path_3d.add_child(new_ability_holder)

func create_selected_trap_holder() ->void:
	var new_trap_holder = selected_Trap_example.instantiate()
	new_trap_holder.holder = true
	new_trap_holder.scale = Vector3(.75,.75,.75)
	gridmap.add_child(new_trap_holder)

func move_selected_trap_ability_holder() ->void:
	var selected_holder = gridmap.get_children()
	for i in selected_holder:
		if i.is_in_group("trap") || i.is_in_group("abilityholder"):
			if camera_on_layer == 1:
				i.position = project_position(get_viewport().get_mouse_position(), 2)
			elif camera_on_layer == 2:
				i.position = project_position(get_viewport().get_mouse_position(), 1.2)

func add_abilty_placement_options() -> void:
	if selected_Ability_example:
		for i in layer_nodes[camera_on_layer-1].get_children():
			if i.is_in_group("enemypath"):
				var new_ability_avail_spot = selected_Ability_example.instantiate()
				new_ability_avail_spot.spot_avail = true
				i.add_child(new_ability_avail_spot)

func add_trap_placement_options() -> void:
	var gridmap_list = gridmap.get_used_cells_by_item(0)  #Item 0 is CavePath
	if selected_Trap:
		for i in gridmap_list:
			if i.y == (camera_on_layer-1)*-10:
				var new_trap_avail_spot = selected_Trap_example.instantiate()
				new_trap_avail_spot.spot_avail = true
				new_trap_avail_spot.position = gridmap.map_to_local(i)
				new_trap_avail_spot.remove_from_group("trap")
				gridmap.add_child(new_trap_avail_spot)

func end_select_trap_ability_check() -> void:
	selected_Trap = null
	ray_cast_3d.collision_mask = mask_reset
	get_tree().call_group("example", "queue_free")

func mouse_raycast() -> void:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	mouse_position_3d = project_position (mouse_position, 0)
	ray_cast_3d.global_position = mouse_position_3d
	ray_cast_3d.target_position = project_local_ray_normal(mouse_position) * ray_extend
	ray_cast_3d.force_raycast_update()
