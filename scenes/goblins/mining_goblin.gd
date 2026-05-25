extends PathFollow3D

@onready var bankandquota = get_tree().get_first_node_in_group("bankandquota")

@export var mining_rate := 1 #Number of seconds
@export var mining_amount_per_tick :=1

@onready var mine_gold: Node3D = $MineGold

func _ready() -> void:
	$MiningTimer.wait_time = mining_rate

func _on_mining_timer_timeout() -> void:
	if get_parent().current_gold > mining_amount_per_tick:
		bankandquota.gold += mining_amount_per_tick
		bankandquota.earned_for_quota += mining_amount_per_tick
		get_parent().lose_gold(mining_amount_per_tick)
		mine_gold.mine_gold()
	else:
		queue_free()
