extends Node3D

@export var trap_cost := 10
@export var speed := 0.0
@export var Max_HP := 5

var current_health: int:
	set(health_in):
		current_health = max(health_in,0)
		if current_health <= 0:
			queue_free()
		
func _ready() -> void:
	current_health = Max_HP
