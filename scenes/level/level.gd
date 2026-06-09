extends Node3D

var layer_unlocked :int = 1
var layers :int =3

@export var gridmap: GridMap
@export var mines_L1 :Array[Path3D]
@export var mines_L2 :Array[Path3D]
@export var mines_L3 :Array[Path3D]

@onready var storyui = get_tree().get_first_node_in_group("storyui")

@onready var ui: MarginContainer = $UI
@onready var enemy_manager: Node3D = $EnemyManager
@onready var ladder_layer_2_sprite_mesh_instance: SpriteMeshInstance = $ladders/LadderLayer2SpriteMeshInstance
@onready var ladder_layer_3_sprite_mesh_instance: SpriteMeshInstance = $ladders/LadderLayer3SpriteMeshInstance
@onready var bankand_quota: Node = $BankandQuota

var all_mines: Array
var max_gold_on_layer: Array[int]
var current_gold_on_layer: Array[int]
 
var floor_cells: Array[Vector3i] = []
var floor_items: Array[int] = []
var floor_all_cells: Array[Array]
var floor_all_items: Array[Array]

func _ready() -> void:
	all_mines = [mines_L1, mines_L2, mines_L3]
	max_gold_on_layer.resize(all_mines.size()) # Sets the size
	max_gold_on_layer.fill(0)
	
	floor_all_cells.resize(all_mines.size())
	floor_all_items.resize(all_mines.size())
	place_mining_goblins()
	var used_cells = gridmap.get_used_cells()
	for i in range(1, all_mines.size()+1):
		for cell in used_cells:
			floor_cells = []
			floor_items = []
			if cell.y == -10*(i-1):
				floor_all_cells[i-1].append(cell)
				floor_all_items[i-1].append(gridmap.get_cell_item(cell))
	hide_floor()
	show_floor(layer_unlocked)
	get_max_gold()

func hide_floor() -> void:
	for i in floor_all_cells.size():
		for cell in floor_all_cells[i-1]:
			gridmap.set_cell_item(cell, -1) # -1 is INVALID_CELL_ITEM

func show_floor(layer) -> void:
	if layer_unlocked <= layers:
		for i in range(floor_all_cells[layer-1].size()):
			gridmap.set_cell_item(floor_all_cells[layer-1][i], floor_all_items[layer-1][i])
	if layer == 2:
		ladder_layer_2_sprite_mesh_instance.visible = true
	elif layer == 3:
		ladder_layer_3_sprite_mesh_instance.visible = true

func show_unlocked_mines() -> void:
	if layer_unlocked <= layers:
		for i in all_mines[layer_unlocked-1]:
			i.visible = true

func check_layer_complete() -> void:
	for i in all_mines[layer_unlocked-1]:
		if i.current_gold > 0:
			return
	if layer_unlocked < layers:
		layer_unlocked += 1
		if layer_unlocked == 2:
			storyui.layer2_opened()
		else:
			new_layer()
	else:
		get_tree().paused = true
		print("game over")

func new_layer() -> void:
	bankand_quota.reset_quota()
	show_unlocked_mines()
	show_floor(layer_unlocked)
	place_mining_goblins()
	get_max_gold()
	ui.unlock_trapabilities()

func place_mining_goblins() -> void:
	if layer_unlocked <= layers:
		for i in all_mines[layer_unlocked-1]:
			i.place_mining_gob()

func get_max_gold() -> void:
	for i in all_mines[layer_unlocked-1]:
		max_gold_on_layer[layer_unlocked-1] += i.max_gold

func get_current_gold() -> float:
	var total_gold_on_layer: float = 0.0
	for i in all_mines[layer_unlocked-1]:
		total_gold_on_layer += i.current_gold
	return total_gold_on_layer
