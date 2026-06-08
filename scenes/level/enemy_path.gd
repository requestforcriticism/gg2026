extends Path3D

@export var my_going_forward_mine :Path3D
@export var my_going_forward_nextpath :Array[Path3D]
@export var my_going_back :Array[Path3D]

func move_me_to_next_path() -> void:
	for i in get_children():
		if i.get_class() == "PathFollow3D":
			if i.progress_ratio == 1.0:
				if my_going_forward_nextpath:
					var forward_path: Path3D = my_going_forward_nextpath.pick_random()
					if forward_path == null:
						print(self)
					i.reparent(forward_path)
				else:
					print("Might be the end of the game.")
			elif i.progress_ratio == 0.0:
				i.reparent(my_going_back.pick_random())

func move_me_to_goldmine() -> void:
	for i in get_children():
		if i.get_class() == "PathFollow3D":
			if i.progress_ratio == 1.0:
				i.reparent(my_going_forward_mine)
