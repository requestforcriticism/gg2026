extends Camera3D

@export var spike_trap_avail: PackedScene
@export var gridmap: GridMap
@export var trap_manager: Node3D

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var bank = get_tree().get_first_node_in_group("bank")
@onready var ui: MarginContainer = $"../UI"

var trap_cost := 20 #Get this from the trap selected from UI
var ray_extend := 100.0 #Distance for Raycast to reach level
var selected_Trap :Object
var mouse_position_3d

func _ready() -> void:
	ui.trap_select.connect(select_trap)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("CancelSelection"):
		end_select_trap_check()
	
	
	mouse_raycast()
	if selected_Trap:
		pass
	
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

func select_trap(new_trap: Object) -> void:
	selected_Trap = new_trap
	add_trap_placement_options()

func add_trap_placement_options() -> void:
	var gridmap_list = gridmap.get_used_cells_by_item(0)  #Item 0 is CavePath
	if selected_Trap:
		for i in gridmap_list:
			var new_spike_avail_spot = spike_trap_avail.instantiate()
			new_spike_avail_spot.position = gridmap.map_to_local(i)
			gridmap.add_child(new_spike_avail_spot)
		#print(selected_Trap)

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
