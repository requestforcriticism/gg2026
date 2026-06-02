extends MeshInstance3D

@export var scale_down: float = 1.9
@export var scale_up: float = 2.1
var direction_y := "up"
var direction_x := "up"

func _physics_process(delta: float) -> void:
	var mat: StandardMaterial3D = mesh.surface_get_material(0)
	mesh.surface_get_material(0)

	if mat && self.get_parent() == get_tree().get_first_node_in_group("mudtrap"):
		if mat.uv1_scale.y >= scale_up - .01:
			direction_y = "down"
		elif mat.uv1_scale.y <= scale_down + .01:
			direction_y = "up"
			
		if direction_y == "up":
			mat.uv1_scale.y = lerp(mat.uv1_scale.y,scale_up,.01)
		else:
			mat.uv1_scale.y = lerp(mat.uv1_scale.y,scale_down,.01)
		
		if mat.uv1_scale.x >= scale_up - .01:
			direction_x = "down"
		elif mat.uv1_scale.x <= scale_down + .01:
			direction_x = "up"
			
		if direction_x == "up":
			mat.uv1_scale.x = lerp(mat.uv1_scale.x,scale_up,.021)
		else:
			mat.uv1_scale.x = lerp(mat.uv1_scale.x,scale_down,.021)
