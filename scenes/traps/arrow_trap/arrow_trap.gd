extends "res://scenes/traps/arrow_trap/arrow_trap_base.gd"

@onready var selected_mesh: MeshInstance3D = $SelectedMesh
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	mark_options = [$Wall/hole/Marker3D,$Wall/hole2/Marker3D,$Wall/hole3/Marker3D,$Wall/hole4/Marker3D,$Wall/hole5/Marker3D,$Wall2/hole/Marker3D,$Wall2/hole2/Marker3D,$Wall2/hole3/Marker3D,$Wall2/hole4/Marker3D,$Wall2/hole5/Marker3D] 
	mark_options.shuffle()
	mark_options_size = mark_options.size()
	shoot_timer.wait_time = arrow_fire_rate[trap_level]
	animation_player.play("placed")

func upgrade() -> void:
	trap_level += 1
	
func selected() -> void:
	if selected_mesh.visible == false:
		selected_mesh.visible = true

func deselected() -> void:
	if selected_mesh.visible == true:
		selected_mesh.visible = false
