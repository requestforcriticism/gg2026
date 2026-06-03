extends Node3D

@onready var bankandquota = get_tree().get_first_node_in_group("bankandquota")
@onready var gridmap = get_tree().get_first_node_in_group("gridmap")
@onready var UI = get_tree().get_first_node_in_group("UI")

func build_trap(trap2Build: Object, trap_position: Vector3,cell: Vector3, trap_rotation: float) -> void:
	var new_trap = trap2Build.instantiate()
	if bankandquota.gold >= new_trap.trap_cost[0]:
		bankandquota.gold -= new_trap.trap_cost[0]
		new_trap.position = trap_position
		new_trap.rotation.y = trap_rotation
		add_child(new_trap)
		if !new_trap.get_groups().has("dirtblock"):
			gridmap.set_cell_item(cell, 1)
		elif new_trap.get_groups().has("dirtblock"):
			UI.start_cooldown_timer("dirtblock")

func activate_ability(ability2activate: Object, Path3Doffset: float, Path2place: Path3D) -> void:
	var new_ability = ability2activate.instantiate()
	if bankandquota.gold >= new_ability.ability_cost[0]:
		bankandquota.gold -= new_ability.ability_cost[0]
		new_ability.progress = Path3Doffset
		Path2place.add_child(new_ability)
		if new_ability.get_groups().has("boulder"):
			UI.start_cooldown_timer("boulder")
		
