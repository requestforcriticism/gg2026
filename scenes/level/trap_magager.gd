extends Node3D

@export var spike_trap: PackedScene

func build_trap(trap_position:Vector3) -> void:
	var new_trap = spike_trap.instantiate()
	add_child(new_trap)
	new_trap.global_position = trap_position

func get_trap_cost() -> int:
	var cost
	return cost
