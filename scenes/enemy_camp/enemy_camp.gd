extends Path3D

@export var starting_stolen_gold := 0

@onready var ui: MarginContainer = $"../UI"

var stolen_gold: int:
	set(gold_in):
		stolen_gold = max(gold_in,0)
		if stolen_gold:
			ui.set_stolen_label(stolen_gold)

func _ready() -> void:
	stolen_gold = starting_stolen_gold
