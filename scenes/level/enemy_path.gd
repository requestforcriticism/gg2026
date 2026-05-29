extends Path3D

@export var bag_to_drop_scene: PackedScene
@export var my_going_forward_mine :Path3D
@export var my_going_forward_nextpath :Array[Path3D]
@export var my_going_back :Array[Path3D]

func move_me_to_next_path() -> void:
	for i in get_children():
		if i.get_class() == "PathFollow3D":
			if i.progress_ratio == 1.0:
				if my_going_forward_nextpath:
					i.reparent(my_going_forward_nextpath.pick_random())
				else:
					print("Might be the end of the game.")
			elif i.progress_ratio == 0.0:
				i.reparent(my_going_back.pick_random())

func move_me_to_goldmine() -> void:
	for i in get_children():
		if i.get_class() == "PathFollow3D":
			if i.progress_ratio == 1.0:
				i.reparent(my_going_forward_mine)

func create_bag_to_drop(gold_in_bag: int,enemy_global_pos: Vector3, forward) -> void:
	var new_bag = bag_to_drop_scene.instantiate()
	new_bag.position = enemy_global_pos
	new_bag.Gold_in_Bag = gold_in_bag
	gold_in_bag = 0
	var travel_angle = atan2(forward.x, forward.z)
	new_bag.rotation.y = travel_angle + PI/2 #degrees keeps the bag collision correct.
	add_child(new_bag)
