extends Node

@export var starting_gold := 999999

@onready var label: Label = $Label

var gold: int:
	set(gold_in):
		gold = max(gold_in,0)
		
func _ready() -> void:
	gold = starting_gold
