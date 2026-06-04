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

func purchase_items(enemy:Object,gold_earned:int,current_hp:float,max_hp:int, damage_taken:Array,dam_take_index:Array, items_purchased:Array) -> void:
	if gold_earned > 0:
		if current_hp < floor(max_hp/2):
			enemy.purchase_health_potion()
			gold_earned -= 1
			purchase_items(enemy,gold_earned,current_hp,max_hp, damage_taken,dam_take_index, items_purchased)
		elif !items_purchased[dam_take_index.find(4)] && gold_earned >=3:
			enemy.items_purchased[dam_take_index.find(4)] = 1
			gold_earned -= 3
			check_4_pike(enemy, dam_take_index.find(4))
			purchase_items(enemy,gold_earned,current_hp,max_hp, damage_taken,dam_take_index, items_purchased)
		elif !items_purchased[dam_take_index.find(3)] && gold_earned >=3:
			enemy.items_purchased[dam_take_index.find(3)] = 1
			gold_earned -= 3
			check_4_pike(enemy, dam_take_index.find(3))
			purchase_items(enemy,gold_earned,current_hp,max_hp, damage_taken,dam_take_index, items_purchased)
		elif !items_purchased[dam_take_index.find(2)] && gold_earned >=3:
			enemy.items_purchased[dam_take_index.find(2)] = 1
			gold_earned -= 3
			check_4_pike(enemy, dam_take_index.find(2))
			purchase_items(enemy,gold_earned,current_hp,max_hp, damage_taken,dam_take_index, items_purchased)
		elif !items_purchased[dam_take_index.find(1)] && gold_earned >=3:
			enemy.items_purchased[dam_take_index.find(1)] = 1
			gold_earned -= 3
			check_4_pike(enemy, dam_take_index.find(1))
			purchase_items(enemy,gold_earned,current_hp,max_hp, damage_taken,dam_take_index, items_purchased)
		elif !items_purchased[dam_take_index.find(0)] && gold_earned >=3:
			enemy.items_purchased[dam_take_index.find(0)] = 1
			gold_earned -= 3
			check_4_pike(enemy, dam_take_index.find(0))
			purchase_items(enemy,gold_earned,current_hp,max_hp, damage_taken,dam_take_index, items_purchased)
		elif !items_purchased[5] && gold_earned >=3:
			enemy.items_purchased[5] = 1
			gold_earned -= 3
			enemy.purchased_bag()
			purchase_items(enemy,gold_earned,current_hp,max_hp, damage_taken,dam_take_index, items_purchased)	
		elif current_hp < max_hp:
			enemy.purchase_health_potion()
			gold_earned -= 1
			purchase_items(enemy,gold_earned,current_hp,max_hp, damage_taken,dam_take_index, items_purchased)
		elif current_hp == max_hp:
			enemy.increase_max_health()
			gold_earned -= 1
			purchase_items(enemy,gold_earned,current_hp,max_hp, damage_taken,dam_take_index, items_purchased)
		else:
			print("some error")
	
func check_4_pike(enemy:Object, ind:int) -> void:
	if ind == 4:
		enemy.purchased_pike()
