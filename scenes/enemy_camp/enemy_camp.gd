extends Path3D

@export var my_going_forward_first_path :Path3D

@export var starting_stolen_gold := 0

@onready var ui: MarginContainer = $"../UI"

var stolen_gold: int:
	set(gold_in):
		stolen_gold = max(gold_in,0)
		if stolen_gold:
			ui.set_stolen_label(stolen_gold)

func _ready() -> void:
	stolen_gold = starting_stolen_gold

func _process(delta: float) -> void:
	reorg_children()

func move_me_to_next_path() -> void:
	for i in get_children():
		if i.is_in_group("enemy"):
			if !i.rdy_to_leave:
				i.reparent(my_going_forward_first_path)

func reorg_children()-> void:
	if get_children():
		var path_children :Array[PathFollow3D] = []
		for i in get_children():
			if i.get_class() == "PathFollow3D":
				path_children.append(i)
		for i in path_children:
			i.progress_ratio = float(path_children.find(i)) / path_children.size() + (1.0/path_children.size())/2.0
