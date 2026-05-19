extends Node3D

@export var trap_cost := 50

@export var spike_thrust_damage := 20

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var enemies_on_trap: Array = []
var spikes_active := false

func _process(delta: float) -> void:
	#print("enemies_on_trap: ", enemies_on_trap)
	pass

func _on_area_3d_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	if area.is_in_group("enemy"):
		enemies_on_trap.append(area)
		if !spikes_active:
			animation_player.play("spike_buildup")
			spikes_active = true
		
func _on_area_3d_area_shape_exited(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	if area.is_in_group("enemy"):
		enemies_on_trap.erase(area)

func spike_thrust(area) -> void:
	area.get_parent().current_health -= spike_thrust_damage


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#print("finished :", anim_name )
	if anim_name == "spike_buildup":
		animation_player.play("spike_thrust")
	if anim_name == "spike_thrust":
		spikes_active = false
	
