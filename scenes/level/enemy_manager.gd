extends Node3D

@export var base_enemy_scene: PackedScene

@onready var base_enemy_spawn_timer: Timer = $BaseEnemySpawnTimer

func spawn_base_enemy() -> void:
	var new_enemy = base_enemy_scene.instantiate()
	add_sibling(new_enemy)
