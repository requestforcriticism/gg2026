extends PathFollow3D

@export var bag_to_drop_scene: PackedScene

@export var base_speed := 2.0
@export var offset_value := 0.0
@export var max_health := 50
@export var mining_rate := 1 #Number of seconds
@export var return_gold_rate := .5 #Number of seconds
@export var mining_amount_per_tick :=1
@export var max_gold_capacity := 5

var gold_in_bag := 0
var rdy_to_leave := false
var speed :float

var forward :Vector3
var travel_angle :float
var animate_direction :String

enum ENEMY_STATE {TRAVEL_IN, TRAVEL_OUT, MINING, RETURN_GOLD}
var state := ENEMY_STATE.TRAVEL_IN

@onready var stolen = get_tree().get_first_node_in_group("stolen")
@onready var mine_gold: Node3D = $MineGold
@onready var mining_timer: Timer = $MiningTimer
@onready var return_gold_timer: Timer = $ReturnGoldTimer
@onready var death_timer: Timer = $DeathTimer
@onready var progress_bar: ProgressBar = $SubViewport/ProgressBar
@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@onready var collision_shape_3d: CollisionShape3D = $EnemyArea3D/CollisionShape3D

var current_health: int:
	set(health_in):
		current_health = health_in
		progress_bar.value = current_health
		if current_health < 1:
			if gold_in_bag != 0:
				create_bag_to_drop()
			animated_sprite_3d.play("die")
			set_physics_process(false)
			collision_shape_3d.set_deferred("disabled",true)
			death_timer.start()

func _ready() -> void:
	speed = base_speed
	current_health = max_health
	progress_bar.max_value = max_health
	progress_bar.value = current_health
	mining_timer.wait_time = mining_rate
	return_gold_timer.wait_time = return_gold_rate

func _physics_process(delta: float) -> void:
	do_state_stuff(delta)
	

func do_state_stuff(delta) -> void:
	if state == ENEMY_STATE.TRAVEL_IN:
		progress += delta * speed
		h_offset = offset_value
		figure_out_travel_animation()
		animated_sprite_3d.visible = true
		if progress_ratio == 1.0:
			speed = 0.0
			state = ENEMY_STATE.MINING
			to_goldmine()
	elif state == ENEMY_STATE.MINING:
		h_offset = 0.0
		figure_out_mining_animation()
		if mining_timer.is_stopped():
			mining_timer.start()
	elif state == ENEMY_STATE.TRAVEL_OUT:
		progress -= delta * speed
		h_offset = offset_value
		figure_out_travel_animation()
		animated_sprite_3d.visible = true
		if progress_ratio == 0.0:
			#check if on 1st floor. if not, go to floor n-1.  else:
			speed = 0.0
			state = ENEMY_STATE.RETURN_GOLD
			to_return_gold()
	elif state == ENEMY_STATE.RETURN_GOLD:
		h_offset = 0.0
		animated_sprite_3d.play("return_gold")
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

func figure_out_travel_animation() -> void:
	forward = -global_transform.basis.z
	travel_angle = rad_to_deg(atan2(forward.x, forward.z))
	if state == ENEMY_STATE.TRAVEL_IN:
		animate_direction = "walking_left"
		if travel_angle > 45.0 || travel_angle < -135.0:
			animate_direction = "walking_right"
	elif state == ENEMY_STATE.TRAVEL_OUT:
		animate_direction = "walking_right"
		if travel_angle > 45.0 || travel_angle < -135.0:
			animate_direction = "walking_left"
	else:
		print("something messed up here.")
	animated_sprite_3d.play(animate_direction)

func figure_out_mining_animation() -> void:
	if progress_ratio < 0.41:
		animated_sprite_3d.play("mining_right")
	elif progress_ratio > 0.59:
		animated_sprite_3d.play("mining_left")
	else:
		animated_sprite_3d.play("mining_up")

func create_bag_to_drop() -> void:
	var new_bag = bag_to_drop_scene.instantiate()
	new_bag.global_position = global_position
	new_bag.Gold_in_Bag = gold_in_bag
	forward = -global_transform.basis.z
	travel_angle = atan2(forward.x, forward.z)
	new_bag.rotation.y = travel_angle + PI/2 #degrees keeps the bag collision correct.
	get_parent().add_sibling(new_bag)

func _on_mining_timer_timeout() -> void:
	if gold_in_bag < max_gold_capacity && get_parent().current_gold > 0:
		$MineGold.visible = true
		get_parent().lose_gold(mining_amount_per_tick)
		gold_in_bag += 1
		mine_gold.mine_gold() #play animation
	else:
		$MineGold.visible = false
		mining_timer.stop()
		rdy_to_leave = true
		animated_sprite_3d.visible = false
		back_to_path() 
		state = ENEMY_STATE.TRAVEL_OUT
		progress_ratio = 1.0
		speed = base_speed * 1.25

func _on_return_gold_timer_timeout() -> void:
	if gold_in_bag > 0:
		$MineGold.visible = true
		stolen.stolen_gold += 1
		gold_in_bag -= 1
		mine_gold.mine_gold() #play animation
	else:
		$MineGold.visible = false
		return_gold_timer.stop()
		rdy_to_leave = false
		state = ENEMY_STATE.TRAVEL_IN
		speed = base_speed
		animated_sprite_3d.visible = false
		progress_ratio = 0.0
		back_to_path()

func _on_death_timer_timeout() -> void:
	queue_free()
