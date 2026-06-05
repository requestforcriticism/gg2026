extends "res://scenes/traps/spike_trap/spike_trap_base.gd"

@export var trap_cost := [51,100,200]
@export var passive_spike_buildup_damage := [2,4,8]
@export var spike_thrust_damage := [20,40,80]

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var spike_buildup_timer: Timer = $SpikeBuildupTimer

var enemies_on_trap: Array = []
var spikes_active := false
var trap_level := 0

func _on_initialdetect_area_3d_area_entered(area: Area3D) -> void:
	if area:
		if area.is_in_group("enemy"):
			enemies_on_trap.append(area.get_parent())
			if !spikes_active:
				animation_player.play("spike_buildup")
				spike_buildup_timer.start()
				spikes_active = true

func _on_initialdetect_area_3d_area_exited(area: Area3D) -> void:
	if area:
		if area.is_in_group("enemy"):
			enemies_on_trap.erase(area.get_parent())

func spike_buildup_passive_damage() -> void:
	for i in enemies_on_trap:
		if i:
			if i.items_purchased[0]:
				i.current_health -= floori(passive_spike_buildup_damage[trap_level]/2)
				i.damage_taken[0] += floori(passive_spike_buildup_damage[trap_level]/2)
				i.damage_taken[2] += (1.0-i.slowed_perc) * passive_spike_buildup_damage[trap_level]/2.0
			else:
				i.current_health -= passive_spike_buildup_damage[trap_level]
				i.damage_taken[0] += passive_spike_buildup_damage[trap_level]
				i.damage_taken[2] += (1.0-i.slowed_perc) * passive_spike_buildup_damage[trap_level]
		else:
			enemies_on_trap.erase(i)

func spike_thrust() -> void:
	for i in enemies_on_trap:
		if i:
			if i.items_purchased[0]:
				i.current_health -= floori(spike_thrust_damage[trap_level]/2)
				i.damage_taken[0] += floori(spike_thrust_damage[trap_level]/2)
			else:
				i.current_health -= spike_thrust_damage[trap_level]
				i.damage_taken[0] += spike_thrust_damage[trap_level]
		else:
			enemies_on_trap.erase(i)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "spike_buildup":
		spike_buildup_timer.stop()
		animation_player.play("spike_thrust")
		spike_thrust()
	if anim_name == "spike_thrust":
		if enemies_on_trap:
			animation_player.play("spike_buildup")
			spike_buildup_timer.start()
		else:
			spikes_active = false

@onready var selected_mesh: MeshInstance3D = $SelectedMesh

func selected() -> void:
	if selected_mesh.visible == false:
		selected_mesh.visible = true

func deselected() -> void:
	if selected_mesh.visible == true:
		selected_mesh.visible = false
