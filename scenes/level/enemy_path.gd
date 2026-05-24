extends Path3D

@export var my_going_forward_mine :Path3D
@export var my_going_forward_nextpath :Path3D
@export var my_going_back :Path3D

func _process(delta: float) -> void:
	pass

func move_me_to_goldmine() -> void:
	for i in get_children():
		if i.get_class() == "PathFollow3D":
			if i.progress_ratio == 1.0:
				i.reparent(my_going_forward_mine)

func move_me_to_return() -> void:
	for i in get_children():
		if i.get_class() == "PathFollow3D":
			if i.progress_ratio == 0.0:
				i.reparent(my_going_back)
