extends Node

@export var starting_gold := 98765
@export var starting_gold_earned := 0
@export var quota := [35,100,850]

@onready var level: Node3D = $".."
@onready var ui: MarginContainer = $"../UI"

var gold: int:
	set(gold_in):
		gold = max(gold_in,0)
		if gold:
			ui.set_gold_label(gold)

var earned_for_quota: int:
	set(gold_in):
		earned_for_quota = max(gold_in,0)
		if earned_for_quota <= quota[level.layer_unlocked-1]:
			ui.set_quota_label(earned_for_quota, quota[level.layer_unlocked-1])

func _ready() -> void:
	gold = starting_gold
	earned_for_quota = starting_gold_earned

func reset_quota() -> void:
	earned_for_quota = 0
