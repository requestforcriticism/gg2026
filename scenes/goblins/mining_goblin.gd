extends PathFollow3D

@onready var bankandquota = get_tree().get_first_node_in_group("bankandquota")

@export var mining_rate := 1 #Number of seconds
@export var mining_amount_per_tick :=1

@onready var mine_gold: Node3D = $MineGold
@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D

func _ready() -> void:
	$MiningTimer.wait_time = mining_rate

func _physics_process(delta: float) -> void:
	figure_out_mining_animation()

func _on_mining_timer_timeout() -> void:
	if get_parent().current_gold >= mining_amount_per_tick:
		get_parent().lose_gold(mining_amount_per_tick)
		bankandquota.gold += mining_amount_per_tick
		bankandquota.earned_for_quota += mining_amount_per_tick
		mine_gold.mine_gold()
	else:
		get_parent().mine_empty()
		queue_free()

func figure_out_mining_animation() -> void:
	if progress_ratio < 0.41:
		animated_sprite_3d.play("mining_right")
	elif progress_ratio > 0.59:
		animated_sprite_3d.play("mining_left")
	else:
		animated_sprite_3d.play("mining_up")
