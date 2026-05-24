extends PathFollow3D

@export var bag_to_drop_scene: PackedScene

@export var base_speed := 2.0
@export var max_health := 50
@export var mining_rate := 1 #Number of seconds
@export var return_gold_rate := .5 #Number of seconds
@export var mining_amount_per_tick :=1
@export var max_gold_capacity := 5

var gold_in_bag := 0
var rdy_to_leave := false
var speed :float

enum ENEMY_STATE {TRAVEL_IN, TRAVEL_OUT, MINING, RETURN_GOLD}
var state := ENEMY_STATE.TRAVEL_IN

@onready var stolen = get_tree().get_first_node_in_group("stolen")
@onready var mine_gold: Node3D = $MineGold
@onready var mining_timer: Timer = $MiningTimer
@onready var return_gold_timer: Timer = $ReturnGoldTimer

var current_health: int:
	set(health_in):
		current_health = health_in
		if current_health < 1:
			if gold_in_bag != 0:
				create_bag_to_drop()
			queue_free()

func _ready() -> void:
	speed = base_speed
	current_health = max_health
	mining_timer.wait_time = mining_rate
	return_gold_timer.wait_time = return_gold_rate
	
func _physics_process(delta: float) -> void:
	do_state_stuff(delta)

func do_state_stuff(delta) -> void:
	if state == ENEMY_STATE.TRAVEL_IN:
		progress += delta * speed
		if progress_ratio == 1.0:
			speed = 0.0
			state = ENEMY_STATE.MINING
			to_goldmine()
	elif state == ENEMY_STATE.MINING:
		if mining_timer.is_stopped():
			mining_timer.start()
	elif state == ENEMY_STATE.TRAVEL_OUT:
		progress -= delta * speed
		if progress_ratio == 0.0:
			#check if on 1st floor. if not, go to floor n-1.  else:
			speed = 0.0
			state = ENEMY_STATE.RETURN_GOLD
			to_return_gold()
	elif state == ENEMY_STATE.RETURN_GOLD:
		if return_gold_timer.is_stopped():
			return_gold_timer.start()
	else:
		print("Something messed up.")
	
func to_goldmine() -> void:
	self.get_parent().move_me_to_goldmine()

func to_return_gold() -> void:
	self.get_parent().move_me_to_return()

func back_to_path() -> void:
	self.get_parent().move_me_to_path()

func leave() -> void:
	print(state)
	if state == ENEMY_STATE.TRAVEL_IN || state == ENEMY_STATE.TRAVEL_OUT:
		state = ENEMY_STATE.TRAVEL_OUT
		rdy_to_leave = true

func create_bag_to_drop() -> void:
	var new_bag = bag_to_drop_scene.instantiate()
	new_bag.global_position = global_position
	new_bag.Gold_in_Bag = gold_in_bag
	get_parent().add_sibling(new_bag)

func _on_mining_timer_timeout() -> void:
	if gold_in_bag < max_gold_capacity && get_parent().current_gold > 0:
		get_parent().lose_gold(mining_amount_per_tick)
		gold_in_bag += 1
		mine_gold.mine_gold() #play animation
	else:
		mining_timer.stop()
		rdy_to_leave = true
		back_to_path()
		state = ENEMY_STATE.TRAVEL_OUT
		progress_ratio = 1.0
		speed = base_speed * 1.25

func _on_return_gold_timer_timeout() -> void:
	if gold_in_bag > 0:
		stolen.stolen_gold += 1
		gold_in_bag -= 1
		mine_gold.mine_gold() #play animation
	else:
		return_gold_timer.stop()
		rdy_to_leave = false
		state = ENEMY_STATE.TRAVEL_IN
		progress_ratio = 0.0
		speed = base_speed
		back_to_path()
