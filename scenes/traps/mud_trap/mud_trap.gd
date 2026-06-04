extends "res://scenes/traps/mud_trap/mud_trap_base.gd"

@export var trap_cost := [49,100,200]

var speed_reduce_percent := [0.4,0.6,0.8] # -40% speed

var enemies_on_trap: Array = []
var trap_level := 0


func _physics_process(delta: float) -> void:
	if enemies_on_trap:
		for i in enemies_on_trap:
			if i.items_purchased[2]:
				i.slowed_perc = 1.0 - speed_reduce_percent[trap_level]/2.0
			else:
				i.slowed_perc = 1.0 - speed_reduce_percent[trap_level]

func _on_find_enemy_area_3d_area_entered(area: Area3D) -> void:
	if area:
		if area.is_in_group("enemy"):
			enemies_on_trap.append(area.get_parent())


func _on_find_enemy_area_3d_area_exited(area: Area3D) -> void:
	if area:
		if area.is_in_group("enemy"):
			enemies_on_trap.erase(area.get_parent())
