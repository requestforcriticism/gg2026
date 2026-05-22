extends Path3D

@export var my_goldmine :Path3D


func _process(delta: float) -> void:
	pass

func move_me():
	for i in get_children():
		if i.get_class() == "PathFollow3D":
			if i.progress_ratio == 1.0:
				i.progress_ratio = .5
				i.speed = 0.1
				i. reparent(my_goldmine)
				#move_child(i,my_goldmine.get_index())
#	my_goldmine/enemy_to_move.progress = .5
#	my_goldmine/enemy_to_move.speed = 0
