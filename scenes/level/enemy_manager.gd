extends Node3D

@export var base_enemy_scene: PackedScene

@onready var base_enemy_spawn_timer: Timer = $BaseEnemySpawnTimer
@export var enemy_path_l_1: Path3D

@export var spawn_rate := 2.0

func _ready() -> void:
	base_enemy_spawn_timer.wait_time = spawn_rate

func spawn_base_enemy() -> void:
	var new_enemy = base_enemy_scene.instantiate()
	new_enemy.offset_value = randf_range(-0.3,0.3)
	enemy_path_l_1.add_child(new_enemy)
