extends Node3D

@onready var bank = get_tree().get_first_node_in_group("bank")

#@export var spike_trap: PackedScene
@export var arrow_trap: PackedScene

func build_trap(trap2Build: Object, trap_position:Vector3) -> void:
	var new_trap = trap2Build.instantiate()
	if bank.gold >= new_trap.trap_cost:
		bank.gold -= new_trap.trap_cost
		add_child(new_trap)
		new_trap.global_position = trap_position

func get_trap_cost() -> int:
	var cost
	return cost
