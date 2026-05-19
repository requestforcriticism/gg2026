extends Node

@export var starting_gold := 999999

var gold: int:
	set(gold_in):
		gold = max(gold_in,0)
		
func _ready() -> void:
	gold = starting_gold
