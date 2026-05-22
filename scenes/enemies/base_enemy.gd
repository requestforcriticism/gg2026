extends PathFollow3D

@export var speed := 2.0
@export var max_health := 50
@export var mining_rate := 1 #Number of seconds
@export var mining_amount_per_tick :=1
@export var max_gold_capacity := 5

var gold_in_bag := 0
var rdy_to_leave := false

enum ENEMY_STATE {TRAVEL_IN, TRAVEL_OUT, MINING}
var state := ENEMY_STATE.TRAVEL_IN

@onready var mining_timer: Timer = $MiningTimer

var current_health: int:
	set(health_in):
		current_health = health_in
		if current_health < 1:
			queue_free()

func _ready() -> void:
	current_health = max_health
	mining_timer.wait_time = mining_rate
	
func _physics_process(delta: float) -> void:
	if state == ENEMY_STATE.TRAVEL_IN:
		progress += delta * speed
		if progress_ratio == 1.0:
			speed = 0.0
			state = ENEMY_STATE.MINING
			to_goldmine()
			progress_ratio = 0.5
	elif state == ENEMY_STATE.TRAVEL_OUT:
		pass
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
	if gold_in_bag < max_gold_capacity:
		get_parent().lose_gold(mining_amount_per_tick)
		gold_in_bag += 1
	else:
		mining_timer.stop()
		rdy_to_leave = true
		back_up_path()
		state = ENEMY_STATE.TRAVEL_OUT
