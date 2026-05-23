extends PathFollow3D

@export var base_speed := 2.0
@export var max_health := 50
@export var mining_rate := 1 #Number of seconds
@export var mining_amount_per_tick :=1
@export var max_gold_capacity := 5

var gold_in_bag := 0
var rdy_to_leave := false
var speed :float

enum ENEMY_STATE {TRAVEL_IN, TRAVEL_OUT, MINING}
var state := ENEMY_STATE.TRAVEL_IN

@onready var stolen = get_tree().get_first_node_in_group("stolen")
@onready var mine_gold: Node3D = $MineGold
@onready var mining_timer: Timer = $MiningTimer

var current_health: int:
	set(health_in):
		current_health = health_in
		if current_health < 1:
			queue_free()

func _ready() -> void:
	speed = base_speed
	current_health = max_health
	mining_timer.wait_time = mining_rate
	
func _physics_process(delta: float) -> void:
	if state == ENEMY_STATE.TRAVEL_IN:
		progress += delta * speed
		if progress_ratio == 1.0:
			speed = 0.0
			state = ENEMY_STATE.MINING
			to_goldmine()
	elif state == ENEMY_STATE.TRAVEL_OUT:
		progress -= delta * speed
		if progress_ratio == 0.0:
			#check if on 1st floor. if not, go to floor n-1.  else:
			stolen.stolen_gold += gold_in_bag
			print(stolen.stolen_gold)
			print(gold_in_bag)
			queue_free()
	elif state == ENEMY_STATE.MINING:
		if mining_timer.is_stopped():
			mining_timer.start()
	else:
		print("Something messed up.")
	
func to_goldmine() -> void:
	self.get_parent().move_me_to_goldmine()

func back_up_path() -> void:
	self.get_parent().move_me_to_path()

func _on_mining_timer_timeout() -> void:
	if gold_in_bag < max_gold_capacity && get_parent().current_gold > 0:
		get_parent().lose_gold(mining_amount_per_tick)
		gold_in_bag += 1
		mine_gold.mine_gold()
	else:
		mining_timer.stop()
		rdy_to_leave = true
		back_up_path()
		state = ENEMY_STATE.TRAVEL_OUT
		progress_ratio = 1.0
		speed = base_speed
