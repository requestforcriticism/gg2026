extends "res://scenes/traps/arrow_trap/arrow_trap_base.gd"

@onready var selected_mesh: MeshInstance3D = $SelectedMesh

func selected() -> void:
	if selected_mesh.visible == false:
		selected_mesh.visible = true

func deselected() -> void:
	if selected_mesh.visible == true:
		selected_mesh.visible = false
