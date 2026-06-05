extends Node3D

var layer_unlocked := 1
var layers :=3

@export var gridmap: GridMap
@export var mines_L1 :Array[Path3D]
@export var mines_L2 :Array[Path3D]
@export var mines_L3 :Array[Path3D]

var all_mines :Array

var floor_cells: Array[Vector3i] = []
var floor_items: Array[int] = []
var floor_all_cells: Array[Array]
var floor_all_items: Array[Array]

func _ready() -> void:
	all_mines = [mines_L1, mines_L2, mines_L3]
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

func hide_floor() -> void:
	for i in floor_all_cells.size():
		for cell in floor_all_cells[i-1]:
			gridmap.set_cell_item(cell, -1) # -1 is INVALID_CELL_ITEM

func show_floor(layer) -> void:
	for i in range(floor_all_cells[layer-1].size()):
		gridmap.set_cell_item(floor_all_cells[layer-1][i], floor_all_items[layer-1][i])

func show_unlocked_mines() -> void:
	for i in all_mines[layer_unlocked-1]:
		i.visible = true

func check_layer_complete() -> void:
	for i in all_mines[layer_unlocked-1]:
		if i.current_gold > 0:
			return
	layer_unlocked += 1
	show_unlocked_mines()
	show_floor(layer_unlocked)
	place_mining_goblins()
	printt("layer_unlocked:", layer_unlocked)

func place_mining_goblins() -> void:
	for i in all_mines[layer_unlocked-1]:
		i.place_mining_gob()
