extends Camera3D

@export var gridmap: GridMap
@export var trap_manager: Node3D

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var bank = get_tree().get_first_node_in_group("bank")

var trap_cost := 99999 #Get this from the trap selected from UI
var ray_extend := 100.0 #Distance for Raycast to reach level

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	ray_cast_3d.target_position = project_local_ray_normal(mouse_position) * ray_extend
	ray_cast_3d.force_raycast_update()
	printt(mouse_position,ray_cast_3d.target_position)
	
	if ray_cast_3d.is_colliding():
		if bank.gold >= trap_cost:
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
			var collider = ray_cast_3d.get_collider()
			if collider is GridMap:
				if Input.is_action_pressed("click"):
					var collision_point = ray_cast_3d.get_collision_point()
					var cell = gridmap.local_to_map(collision_point)
					if gridmap.get_cell_item(cell) == 0:
						var tile_position = gridmap.map_to_local(cell)
						#trap_manager.build_turret(tile_position)
						#bank.gold -= trap_cost
		else:
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
