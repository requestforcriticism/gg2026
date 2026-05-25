extends Node3D

@onready var bankandquota = get_tree().get_first_node_in_group("bankandquota")

#@export var spike_trap: PackedScene
@export var arrow_trap: PackedScene

func build_trap(trap2Build: Object, trap_position:Vector3) -> void:
	var new_trap = trap2Build.instantiate()
	if bankandquota.gold >= new_trap.trap_cost:
		bankandquota.gold -= new_trap.trap_cost
		add_child(new_trap)
		new_trap.global_position = trap_position
