extends Node3D

@onready var bankandquota = get_tree().get_first_node_in_group("bankandquota")
@onready var gridmap = get_tree().get_first_node_in_group("gridmap")

func build_trap(trap2Build: Object, trap_position: Vector3,cell: Vector3) -> void:
	var new_trap = trap2Build.instantiate()
	if bankandquota.gold >= new_trap.trap_cost:
		bankandquota.gold -= new_trap.trap_cost
		add_child(new_trap)
		new_trap.global_position = trap_position
		gridmap.set_cell_item(cell, 1)

func activate_ability(ability2activate: Object, progress_ratio: float, Path2place: Path3D) -> void:
	var new_ability = ability2activate.instantiate()
	if bankandquota.gold >= new_ability.trap_cost:
		bankandquota.gold -= new_ability.trap_cost
		new_ability.progress_ratio = progress_ratio
		Path2place.add_child(new_ability)
		
