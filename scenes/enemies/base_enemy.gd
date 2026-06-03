extends PathFollow3D

@export var bag_to_drop_scene: PackedScene

@export var base_speed := 2.0
@export var offset_value := 0.0
@export var max_health := 50
@export var mining_rate := 1 #Number of seconds
@export var return_gold_rate := .5 #Number of seconds
@export var mining_amount_per_tick :=1
@export var base_max_gold_capacity := 5
@export var stunned_length := 1.0

var max_gold_capacity
var gold_in_bag := 0
var returned_gold := 0
var rdy_to_leave := false
var not_dead := true
var wall_2_destroy :Area3D

var forward :Vector3
var travel_angle :float
var animate_direction :String
var slowed_perc := 1.0
var current_base_speed : float
var return_speed_multiplier := 1.25

enum ENEMY_STATE {TRAVEL_IN, TRAVEL_OUT, MINING, MINING_DIRT_WALL, RETURN_GOLD, STUNNED}
var state := ENEMY_STATE.TRAVEL_IN
var previous_state

#	[spike damage, Arrow damage, damage while slowed, mining walls & gold, boulder damage]
var damage_taken: Array[float] = [0.05,0.04,0.03,0.02,0.01]
#	[spike, Arrow, Mud, Pike, Boulder, Bag]
var items_purchased: Array = [0,0,0,0,0,0]

@onready var stolen = get_tree().get_first_node_in_group("enemy_camp")
@onready var mine_gold: Node3D = $MineGold
@onready var mining_timer: Timer = $MiningTimer
@onready var return_gold_timer: Timer = $ReturnGoldTimer
@onready var death_timer: Timer = $DeathTimer
@onready var stunned_timer: Timer = $StunnedTimer
@onready var progress_bar: ProgressBar = $SubViewport/ProgressBar
@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@onready var collision_shape_3d: CollisionShape3D = $EnemyArea3D/CollisionShape3D
@onready var dropped_gold_bag: Node3D = $DroppedGoldBag
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var find_dirt_block_area_3d: Area3D = $FindDirtBlockArea3D

var current_health: float:
	set(health_in):
		if current_health > 0:
			gpu_particles_3d.amount = current_health - health_in
		if current_health != max_health && current_health > health_in:
			gpu_particles_3d.emitting = true
		current_health = max(min(health_in,max_health),0)
		progress_bar.value = current_health
		progress_bar.modulate.h = (progress_bar.value/progress_bar.max_value)*130.0/360.0
		
		if current_health < 1 && not_dead:
			not_dead = false
			dropped_gold_bag.visible = false
			if gold_in_bag != 0:
				create_bag_to_drop()
			animated_sprite_3d.play("die")
			set_physics_process(false)
			collision_shape_3d.set_deferred("disabled",true)
			death_timer.start()

var current_speed: float:
	set(speed_in):
		current_speed = speed_in * slowed_perc

func _ready() -> void:
	max_gold_capacity = base_max_gold_capacity
	current_base_speed = base_speed
	current_speed = current_base_speed
	progress_bar.max_value = max_health
	current_health = max_health
	progress_bar.value = current_health
	mining_timer.wait_time = mining_rate
	return_gold_timer.wait_time = return_gold_rate
	stunned_timer.wait_time = stunned_length

func _physics_process(delta: float) -> void:
	do_state_stuff(delta)
	recover_speed()
	#printt(items_purchased,current_health,max_health)

func get_stunned() -> void:
	stunned_timer.start()
	previous_state = state
	state = ENEMY_STATE.STUNNED
	current_speed = 0.0

func recover_speed() -> void:
	slowed_perc = lerp(slowed_perc,1.0,.01)
	current_speed = current_base_speed

func do_state_stuff(delta) -> void:
	if state == ENEMY_STATE.TRAVEL_IN:
		progress += delta * current_speed
		h_offset = offset_value
		animated_sprite_3d.play(figure_out_travel_animation())
		animated_sprite_3d.visible = true
		if progress_ratio == 1.0:
			if get_parent().my_going_forward_mine.current_gold > 0:
				current_base_speed = 0.0
				current_speed = current_base_speed
				find_dirt_block_area_3d.monitoring = false
				state = ENEMY_STATE.MINING
				find_dirt_block_area_3d.monitoring = false
				to_next_goldmine()
			elif get_parent().my_going_forward_mine.current_gold == 0:
				if get_parent().my_going_forward_mine.closing:
					return
				else:
					to_next_path()
					progress_ratio = 0.0
			else:
				print("Something went wrong switching to next layer")
	elif state == ENEMY_STATE.MINING:
		h_offset = 0.0
		figure_out_mining_animation()
		if mining_timer.is_stopped():
			mining_timer.start()
	elif state == ENEMY_STATE.MINING_DIRT_WALL:
		figure_out_mining_dirt_wall_animation()
		if mining_timer.is_stopped():
			mining_timer.start()
	elif state == ENEMY_STATE.TRAVEL_OUT:
		progress -= delta * current_speed
		h_offset = offset_value
		animated_sprite_3d.play(figure_out_travel_animation())
		animated_sprite_3d.visible = true
		if !dropped_gold_bag.visible && gold_in_bag > 0:
			if items_purchased.max() == 0:
				dropped_gold_bag.position.y = 0.9
			else:
				dropped_gold_bag.position.y = 1.25
			print(dropped_gold_bag.position.y)
			dropped_gold_bag.visible = true
		if progress_ratio == 0.0:
			if get_parent().my_going_back[0].is_in_group("enemy_camp"):
				current_base_speed = 0.0
				current_speed = current_base_speed
				state = ENEMY_STATE.RETURN_GOLD
				find_dirt_block_area_3d.monitoring = false
				dropped_gold_bag.visible = false
				to_next_path()
			else:
				to_next_path()
				progress_ratio = 1.0
	elif state == ENEMY_STATE.RETURN_GOLD:
		h_offset = 0.0
		animated_sprite_3d.play("return_gold")
		if return_gold_timer.is_stopped():
			return_gold_timer.start()
	elif state == ENEMY_STATE.STUNNED:
		animated_sprite_3d.play("stunned")
	else:
		print("Something messed up.")

func to_next_path() -> void:
	self.get_parent().move_me_to_next_path()

func to_next_goldmine() -> void:
	self.get_parent().move_me_to_goldmine()

func leave() -> void:
	if state == ENEMY_STATE.TRAVEL_IN || state == ENEMY_STATE.TRAVEL_OUT:
		state = ENEMY_STATE.TRAVEL_OUT
		find_dirt_block_area_3d.rotation.y = PI
		find_dirt_block_area_3d.monitoring = true
		rdy_to_leave = true

func figure_out_travel_animation() -> String:
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
	return animate_direction
	#animated_sprite_3d.play(animate_direction)

func figure_out_mining_animation() -> void:
	if progress_ratio < 0.41:
		animated_sprite_3d.play("mining_right")
	elif progress_ratio > 0.59:
		animated_sprite_3d.play("mining_left")
	else:
		animated_sprite_3d.play("mining_up")

func figure_out_mining_dirt_wall_animation() -> void:
	if animate_direction == "walking_right":
		animated_sprite_3d.play("mining_right")
	else:
		animated_sprite_3d.play("mining_left")

func create_bag_to_drop() -> void:
	var new_bag = bag_to_drop_scene.instantiate()
	new_bag.position = position
	new_bag.Gold_in_Bag = gold_in_bag
	gold_in_bag = 0
	forward = -global_transform.basis.z
	travel_angle = atan2(forward.x, forward.z)
	new_bag.rotation.y = travel_angle + PI/2 #degrees keeps the bag collision correct.
	get_parent().add_child(new_bag)

func _on_mining_timer_timeout() -> void:
	if state == ENEMY_STATE.MINING:
		if gold_in_bag < max_gold_capacity && get_parent().current_gold > 0:
			$MineGold.visible = true
			get_parent().lose_gold(mining_amount_per_tick)
			gold_in_bag += 1
			damage_taken[4] += 1
			mine_gold.mine_gold() #play animation
		else:
			$MineGold.visible = false
			mining_timer.stop()
			rdy_to_leave = true
			animated_sprite_3d.visible = false
			to_next_path()
			state = ENEMY_STATE.TRAVEL_OUT
			find_dirt_block_area_3d.rotation.y = PI
			find_dirt_block_area_3d.monitoring = true
			progress_ratio = 1.0
			current_base_speed = base_speed * return_speed_multiplier
			current_speed = current_base_speed
	elif state == ENEMY_STATE.MINING_DIRT_WALL:
		if wall_2_destroy && wall_2_destroy.get_parent().current_health > 0:
				wall_2_destroy.get_parent().current_health -= 1
				damage_taken[4] += 1
		else:
			if rdy_to_leave:
				state = ENEMY_STATE.TRAVEL_OUT
				current_speed = current_base_speed
			else:
				state = ENEMY_STATE.TRAVEL_IN
				current_speed = current_base_speed

func _on_return_gold_timer_timeout() -> void:
	if gold_in_bag > 0:
		$MineGold.visible = true
		stolen.stolen_gold += 1
		gold_in_bag -= 1
		returned_gold += 1
		mine_gold.mine_gold() #play animation
		if gold_in_bag == 0:
			stolen.purchase_items(self,returned_gold,current_health,max_health,damage_taken,get_index_4_sorted_array(),items_purchased)
			returned_gold = 0
			#printt(items_purchased,current_health,max_health,mining_rate,max_gold_capacity)
	else:
		$MineGold.visible = false
		return_gold_timer.stop()
		rdy_to_leave = false
		state = ENEMY_STATE.TRAVEL_IN
		find_dirt_block_area_3d.rotation.y = 0.0
		find_dirt_block_area_3d.monitoring = true
		current_base_speed = base_speed
		current_speed = current_base_speed
		animated_sprite_3d.visible = false
		progress_ratio = 0.0
		to_next_path()

func _on_death_timer_timeout() -> void:
	call_deferred("queue_free")

func _on_find_dirt_block_area_3d_area_entered(area: Area3D) -> void:
	state = ENEMY_STATE.MINING_DIRT_WALL
	current_base_speed = 0.0
	current_speed = current_base_speed
	wall_2_destroy = area

func _on_find_dirt_block_area_3d_area_exited(area: Area3D) -> void:
	mining_timer.stop()
	if rdy_to_leave:
		state = ENEMY_STATE.TRAVEL_OUT
		current_base_speed = base_speed*return_speed_multiplier
		current_speed = current_base_speed
	else:
		state = ENEMY_STATE.TRAVEL_IN
		current_base_speed = base_speed
		current_speed = current_base_speed

func _on_stunned_timer_timeout() -> void:
	state = previous_state
	current_speed = current_base_speed

func purchase_health_potion() -> void:
	current_health += 5

func purchased_pike() -> void:
	mining_timer.wait_time = mining_rate/2.0

func purchased_bag() -> void:
	max_gold_capacity = base_max_gold_capacity + 5

func increase_max_health() -> void:
	max_health += 5
	current_health += 5

func get_index_4_sorted_array() -> Array:
	var temp_array: Array[float] = damage_taken.duplicate(false)
	var sorted_indices: Array[int] = [0,0,0,0,0]
	
	for i in range(0,temp_array.size()):
		var max_ind = temp_array.find(temp_array.max())
		sorted_indices[max_ind] = 4-i
		temp_array[max_ind] = -0.1
	
	return sorted_indices
