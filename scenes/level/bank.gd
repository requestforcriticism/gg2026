extends Node

@export var starting_gold := 98765

@onready var ui: MarginContainer = $"../UI"

var gold: int:
	set(gold_in):
		gold = max(gold_in,0)
		if gold:
			ui.set_gold_label(gold)


func _ready() -> void:
	gold = starting_gold
