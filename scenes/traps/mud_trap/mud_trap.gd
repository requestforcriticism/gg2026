extends "res://scenes/traps/mud_trap/mud_trap_base.gd"

var speed_reduce_percent := 0.6 # -40% speed

var enemies_on_trap: Array = []

func _physics_process(delta: float) -> void:
	if enemies_on_trap:
		for i in enemies_on_trap:
			i.slowed = true
			i.current_speed = i.current_base_speed * speed_reduce_percent

func _on_find_enemy_area_3d_area_entered(area: Area3D) -> void:
	if area:
		if area.is_in_group("enemy"):
			enemies_on_trap.append(area.get_parent())


func _on_find_enemy_area_3d_area_exited(area: Area3D) -> void:
	if area:
		if area.is_in_group("enemy"):
			enemies_on_trap.erase(area.get_parent())
