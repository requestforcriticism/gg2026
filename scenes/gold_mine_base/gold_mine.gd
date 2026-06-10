extends Path3D

@export var other_mines_on_layer :Array[Path3D]
@export var my_going_back :Array[Path3D]

@export var mining_goblin_scene: PackedScene

@export var max_gold: int = 1000

@onready var bankquota = get_tree().get_first_node_in_group("bankandquota")
@onready var ui = get_tree().get_first_node_in_group("UI")
@onready var level = get_tree().get_first_node_in_group("level")

var closing := true 

var current_gold: int:
	set(gold_in):
		current_gold = gold_in
		label_3d.text = "Gold: " + str(current_gold)
		var red: Color = Color.RED
		var white: Color = Color.WHITE
		label_3d.modulate = red.lerp(white,float(current_gold)/float(max_gold))

@onready var label_3d: Label3D = $Label3D

func _ready() -> void:
	current_gold = max_gold

func _physics_process(delta: float) -> void:
	reorg_children()

func mine_empty():
	$goldnode.visible = false
	if !get_parent().is_in_group("layer3"):
		$Hole.visible = true
	$Label3D.visible = false
	closing = false
	if !check_if_more_money():
		if bankquota.quota[level.layer_unlocked-1] >= bankquota.earned_for_quota:
			ui.check_if_lost()
		else:
			level.check_layer_complete()

func check_if_more_money() -> bool:
	if other_mines_on_layer:
		for i in other_mines_on_layer:
			if i.current_gold > 0:
				return true
	return false
	
	
			

func move_me_to_next_path() -> void:
	for i in get_children():
		if i.is_in_group("enemy"):
			if i.rdy_to_leave:
				i.reparent(my_going_back.pick_random())

func place_mining_gob()-> void:
	var new_mine_gob = mining_goblin_scene.instantiate()
	add_child(new_mine_gob)

func lose_gold(mining_amount) -> void:
	current_gold -= mining_amount

func reorg_children()-> void:
	if get_children():
		var path_children :Array[PathFollow3D] = []
		for i in get_children():
			if i.get_class() == "PathFollow3D":
				path_children.append(i)
		for i in path_children:
			i.progress_ratio = float(path_children.find(i)) / path_children.size() + (1.0/path_children.size())/2.0
