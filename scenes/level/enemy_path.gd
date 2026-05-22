extends Path3D

@export var my_goldmine :Path3D


func _process(delta: float) -> void:
	pass

func move_me_to_goldmine() -> void:
	for i in get_children():
		if i.get_class() == "PathFollow3D":
			if i.progress_ratio == 1.0:
				i.reparent(my_goldmine)
