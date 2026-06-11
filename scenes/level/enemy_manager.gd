extends Node3D

@export var base_enemy_scene: PackedScene
@export var tank_enemy_scene: PackedScene
@export var fast_enemy_scene: PackedScene

@export var difficulty_curves: Array[Curve]

											#[Base,Tank,Fast]
@export var group_spawn_L1: Array[Array] = [[4,1,1]]
@export var group_spawn_L2: Array[Array] = [[7,2,2],[6,2,2],[5,1,1]]
@export var group_spawn_L3: Array[Array] = [[15,5,5],[12,4,4],[11,4,4],[9,3,3],[8,2,2]]

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

@onready var bankandquota = get_tree().get_first_node_in_group("bankandquota")
@onready var spawn_timer: Timer = $SpawnTimer
@onready var base_enemy_spawn_timer: Timer = $BaseEnemySpawnTimer
@onready var tank_enemy_spawn_timer: Timer = $TankEnemySpawnTimer
@onready var fast_enemy_spawn_timer: Timer = $FastEnemySpawnTimer
@onready var level: Node3D = $".."

@export var enemy_path_l_1: Path3D

@export var base_enemy_spawn_rate := 2.0
@export var tank_enemy_spawn_rate := 2.0
@export var fast_enemy_spawn_rate := 2.0

@export var offset = 0.3

var temp_array: Array = []
var spawn_counter: int
var spawning_counter:Array[int]=[]
var normal_mode_mult:float = .9

func _ready() -> void:
	base_enemy_spawn_timer.wait_time = base_enemy_spawn_rate
	tank_enemy_spawn_timer.wait_time = tank_enemy_spawn_rate
	fast_enemy_spawn_timer.wait_time = fast_enemy_spawn_rate
	base_enemy_spawn_timer.start()
	tank_enemy_spawn_timer.start()
	fast_enemy_spawn_timer.start()	
	spawning_counter.append(group_spawn_L1.size())
	spawning_counter.append(group_spawn_L2.size())
	spawning_counter.append(group_spawn_L3.size())

func normal_mode() -> void:
	base_enemy_base_speed *= normal_mode_mult
	base_enemy_max_health *= normal_mode_mult
	base_enemy_mining_rate *= 1+(1 - normal_mode_mult)
	base_enemy_base_max_gold_capacity = 4
	base_enemy_stunned_length *= 1+(1 - normal_mode_mult)

	tank_enemy_base_speed *= normal_mode_mult
	tank_enemy_max_health *= normal_mode_mult
	tank_enemy_mining_rate *= 1+(1 - normal_mode_mult)
	tank_enemy_base_max_gold_capacity = 6
	tank_enemy_stunned_length *= 1+(1 - normal_mode_mult)

	fast_enemy_base_speed *= normal_mode_mult
	fast_enemy_max_health *= normal_mode_mult
	fast_enemy_mining_rate *= 1+(1 - normal_mode_mult)
	fast_enemy_base_max_gold_capacity = 3
	fast_enemy_stunned_length *= 1+(1 - normal_mode_mult)

func _process(delta: float) -> void:
	if level.layer_unlocked == 1:
		if level.get_current_gold() < level.max_gold_on_layer[level.layer_unlocked-1]*spawning_counter[level.layer_unlocked-1]/(group_spawn_L1.size()+1) && sum_array_elements(group_spawn_L1[spawning_counter[level.layer_unlocked-1]-1]) > 0:
			spawning_counter[level.layer_unlocked-1] -= 1
			spawn_a_bunch_setup(group_spawn_L1[spawning_counter[level.layer_unlocked-1]])
			group_spawn_L1[spawning_counter[level.layer_unlocked-1]] = [0,0,0]
	elif level.layer_unlocked == 2:
		if level.get_current_gold() < level.max_gold_on_layer[level.layer_unlocked-1]*spawning_counter[level.layer_unlocked-1]/(group_spawn_L2.size()+1) && sum_array_elements(group_spawn_L2[spawning_counter[level.layer_unlocked-1]-1]) > 0:
			spawning_counter[level.layer_unlocked-1] -= 1
			spawn_a_bunch_setup(group_spawn_L2[spawning_counter[level.layer_unlocked-1]])
			group_spawn_L2[spawning_counter[level.layer_unlocked-1]] = [0,0,0]
	elif level.layer_unlocked == 3:
		if level.get_current_gold() < level.max_gold_on_layer[level.layer_unlocked-1]*spawning_counter[level.layer_unlocked-1]/(group_spawn_L3.size()+1) && sum_array_elements(group_spawn_L3[spawning_counter[level.layer_unlocked-1]-1]) > 0:
			spawning_counter[level.layer_unlocked-1] -= 1
			spawn_a_bunch_setup(group_spawn_L3[spawning_counter[level.layer_unlocked-1]])
			group_spawn_L3[spawning_counter[level.layer_unlocked-1]] = [0,0,0]

func spawn_a_bunch_setup(input_2_spawn:Array) -> void:
	temp_array = []
	for i in range(0,input_2_spawn[0]):
		temp_array.append("base")
	for i in range(0,input_2_spawn[1]):
		temp_array.append("tank")
	for i in range(0,input_2_spawn[2]):
		temp_array.append("fast")
	temp_array.shuffle()
	spawn_counter = temp_array.size()
	spawn_timer.start()

func spawn_a_bunch_wtimer() -> void:
	spawn_timer.wait_time = randf_range(0.1,0.3)
	spawn_timer.start()
	if temp_array[spawn_counter-1] == "base":
		spawn_base_enemy()
	elif temp_array[spawn_counter-1] == "tank":
		spawn_tank_enemy()
	elif temp_array[spawn_counter-1] == "fast":
		spawn_fast_enemy()
	spawn_counter -= 1
	if spawn_counter == 0:
		spawn_timer.stop()

func sum_array_elements(input_array:Array) -> int:
	var total:int = 0
	for i in input_array:
		total += i
	return total

func spawn_base_enemy() -> void:
	var new_enemy = base_enemy_scene.instantiate()
	new_enemy.offset_value = randf_range(-offset,offset)
	new_enemy.base_speed = base_enemy_base_speed
	new_enemy.max_health = base_enemy_max_health * difficulty_curves[level.layer_unlocked-1].sample(sample_range())
	new_enemy.mining_rate = base_enemy_mining_rate
	new_enemy.base_max_gold_capacity = base_enemy_base_max_gold_capacity
	new_enemy.stunned_length = base_enemy_stunned_length

	enemy_path_l_1.add_child(new_enemy)

func spawn_tank_enemy() -> void:
	var new_enemy = tank_enemy_scene.instantiate()
	new_enemy.offset_value = randf_range(-offset,offset)
	new_enemy.base_speed = tank_enemy_base_speed
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

func spawn_starting_base_enemy() -> void:
	var new_enemy = base_enemy_scene.instantiate()
	new_enemy.offset_value = randf_range(-offset,offset)
	new_enemy.base_speed = base_enemy_base_speed
	new_enemy.max_health = 30
	new_enemy.mining_rate = base_enemy_mining_rate
	new_enemy.base_max_gold_capacity = 1
	new_enemy.stunned_length = base_enemy_stunned_length

	enemy_path_l_1.add_child(new_enemy)

func sample_range() -> float:
	return (1.0 - (level.get_current_gold() / level.max_gold_on_layer[level.layer_unlocked - 1]))

func _on_base_enemy_spawn_timer_timeout() -> void:
	base_enemy_spawn_timer.wait_time = base_enemy_spawn_rate/difficulty_curves[level.layer_unlocked-1].sample(sample_range())

func _on_tank_enemy_spawn_timer_timeout() -> void:
	tank_enemy_spawn_timer.wait_time = tank_enemy_spawn_rate/difficulty_curves[level.layer_unlocked-1].sample(sample_range())

func _on_fast_enemy_spawn_timer_timeout() -> void:
	fast_enemy_spawn_timer.wait_time = fast_enemy_spawn_rate/difficulty_curves[level.layer_unlocked-1].sample(sample_range())
