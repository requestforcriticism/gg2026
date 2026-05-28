extends Node3D

@export var trap_cost := 50

@export var passive_spike_buildup_damage := 2
@export var spike_thrust_damage := 20

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var spike_buildup_timer: Timer = $SpikeBuildupTimer
@onready var collision_shape_3d: CollisionShape3D = $InitialdetectArea3D/CollisionShape3D


var enemies_on_trap: Array = []
var spikes_active := false
var holder := false
var spot_avail := false

func _ready() -> void:
	if spot_avail:
		collision_shape_3d.disabled = true

func _physics_process(delta: float) -> void:
	if holder && !$AnimationPlayer.current_animation == "holder":
		$AnimationPlayer.stop()
		$AnimationPlayer.play("holder")
	elif spot_avail && !$AnimationPlayer.current_animation == "spot_avail":
		$AnimationPlayer.stop()
		$AnimationPlayer.play("spot_avail")

func _on_initialdetect_area_3d_area_entered(area: Area3D) -> void:
	if area:
		if area.is_in_group("enemy"):
			enemies_on_trap.append(area)
			if !spikes_active:
				animation_player.play("spike_buildup")
				spike_buildup_timer.start()
				spikes_active = true

func _on_initialdetect_area_3d_area_exited(area: Area3D) -> void:
	if area:
		if area.is_in_group("enemy"):
			enemies_on_trap.erase(area)

func spike_buildup_passive_damage() -> void:
	for i in enemies_on_trap:
		if i:
			i.get_parent().current_health -= passive_spike_buildup_damage
		else:
			enemies_on_trap.erase(i)

func spike_thrust() -> void:
	for i in enemies_on_trap:
		if i:
			i.get_parent().current_health -= spike_thrust_damage
		else:
			enemies_on_trap.erase(i)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "spike_buildup":
		spike_buildup_timer.stop()
		animation_player.play("spike_thrust")
		spike_thrust()
	if anim_name == "spike_thrust":
		spikes_active = false
	
