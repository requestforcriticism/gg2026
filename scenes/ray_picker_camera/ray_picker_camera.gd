extends Camera3D

@export var gridmap: GridMap
@export var trap_manager: Node3D

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var bank = get_tree().get_first_node_in_group("bank")
@onready var ui: MarginContainer = $"../UI"

var trap_cost := 20 #Get this from the trap selected from UI
var ray_extend := 100.0 #Distance for Raycast to reach level
var selected_Trap :Object

func _ready() -> void:
	ui.trap_select.connect(select_trap)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	#ray_cast_3d.target_position = project_local_ray_normal(mouse_position) * ray_extend
	
	# converted that 2d mouse position, into 3d global space, ith a z depth of 0
	var mouse_position_3d = project_position (mouse_position, 0)
	# move the raycast object to that position
	ray_cast_3d.global_position = mouse_position_3d
	# then cast from where the raycast3d object is, then along the normal
	ray_cast_3d.target_position = project_local_ray_normal(mouse_position) * ray_extend
	
	ray_cast_3d.force_raycast_update()
	
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
						#bank.gold -= trap_cost
			else:
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func select_trap(trap: Object):
	selected_Trap = trap
