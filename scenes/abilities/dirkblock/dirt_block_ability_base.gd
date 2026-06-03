extends Node3D

@export var trap_cost := [0]
@export var speed := 0.0
@export var Max_HP := 5

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D

var trap_level:int :
	set(level_in):
		trap_level = level_in

var current_health: int:
	set(health_in):
		if current_health > 0:
			gpu_particles_3d.amount = 16
		current_health = max(health_in,0)
		if current_health != Max_HP || current_health != 0:
			gpu_particles_3d.emitting = true
		if current_health <= 0:
			gpu_particles_3d.amount = 128
			gpu_particles_3d.emitting = true
			$Wall.visible = false
			$Area3D.monitorable = false
			$DeathTimer.start()
		
func _ready() -> void:
	current_health = Max_HP
	animation_player.play("placed")


func _on_death_timer_timeout() -> void:
	queue_free()
