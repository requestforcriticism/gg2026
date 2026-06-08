extends Node3D

@export var base_enemy_scene: PackedScene
@export var tank_enemy_scene: PackedScene
@export var fast_enemy_scene: PackedScene

@export var difficulty_curves: Array[Curve]

@export var base_enemy_base_speed := 2.0
@export var base_enemy_max_health := 50
@export var base_enemy_mining_rate := 1.0
@export var base_enemy_base_max_gold_capacity := 5
@export var base_enemy_stunned_length := 1.0

@export var tank_enemy_base_speed := 1.7
@export var tank_enemy_max_health := 100
@export var tank_enemy_mining_rate := .75
@export var tank_enemy_base_max_gold_capacity := 8
@export var tank_enemy_stunned_length := 0.5

@export var fast_enemy_base_speed := 2.7
@export var fast_enemy_max_health := 60
@export var fast_enemy_mining_rate := 1.25
@export var fast_enemy_base_max_gold_capacity := 4
@export var fast_enemy_stunned_length := 1.5


@onready var base_enemy_spawn_timer: Timer = $BaseEnemySpawnTimer
@onready var tank_enemy_spawn_timer: Timer = $TankEnemySpawnTimer
@onready var fast_enemy_spawn_timer: Timer = $FastEnemySpawnTimer
@onready var level: Node3D = $".."

@export var enemy_path_l_1: Path3D

@export var base_enemy_spawn_rate := 2.0
@export var tank_enemy_spawn_rate := 2.0
@export var fast_enemy_spawn_rate := 2.0

@export var offset = 0.3

func _ready() -> void:
	base_enemy_spawn_timer.wait_time = base_enemy_spawn_rate
	tank_enemy_spawn_timer.wait_time = base_enemy_spawn_rate
	fast_enemy_spawn_timer.wait_time = base_enemy_spawn_rate

func spawn_base_enemy() -> void:
	var new_enemy = base_enemy_scene.instantiate()
	new_enemy.offset_value = randf_range(-offset,offset)
	new_enemy.base_speed = base_enemy_base_speed
	new_enemy.max_health = base_enemy_max_health * difficulty_curves[level.layer_unlocked-1].sample(sample_range())
	print(new_enemy.max_health)
	new_enemy.mining_rate = base_enemy_mining_rate
	new_enemy.base_max_gold_capacity = base_enemy_base_max_gold_capacity
	new_enemy.stunned_length = base_enemy_stunned_length

	enemy_path_l_1.add_child(new_enemy)

func spawn_tank_enemy() -> void:
	var new_enemy = tank_enemy_scene.instantiate()
	new_enemy.offset_value = randf_range(-offset,offset)
	new_enemy.base_speed = base_enemy_base_speed
	new_enemy.max_health = tank_enemy_max_health * difficulty_curves[level.layer_unlocked-1].sample(sample_range())
	new_enemy.mining_rate = tank_enemy_mining_rate
	new_enemy.base_max_gold_capacity = tank_enemy_base_max_gold_capacity
	new_enemy.stunned_length = tank_enemy_stunned_length
	
	enemy_path_l_1.add_child(new_enemy)

func spawn_fast_enemy() -> void:
	var new_enemy = fast_enemy_scene.instantiate()
	new_enemy.offset_value = randf_range(-offset,offset)
	new_enemy.base_speed = fast_enemy_base_speed
	new_enemy.max_health = fast_enemy_max_health * difficulty_curves[level.layer_unlocked-1].sample(sample_range())
	new_enemy.mining_rate = fast_enemy_mining_rate
	new_enemy.base_max_gold_capacity = fast_enemy_base_max_gold_capacity
	new_enemy.stunned_length = fast_enemy_stunned_length
	
	enemy_path_l_1.add_child(new_enemy)

func sample_range() -> float:
	return (1.0 - (level.get_current_gold() / level.max_gold_on_layer[level.layer_unlocked - 1]))
