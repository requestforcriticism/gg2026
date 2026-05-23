extends MarginContainer

signal trap_select(A3d)

@export var spike_trap: PackedScene
@export var arrow_trap: PackedScene

@onready var bank = get_tree().get_first_node_in_group("bank")
@onready var stolen = get_tree().get_first_node_in_group("stolen")

@onready var gold_label: Label = $Gold_Quota/GoldLabel
@onready var quota_label: Label = $Gold_Quota/QuotaLabel
@onready var stolen_label: Label = $HumanStole/StolenLabel


func _ready() -> void:
	set_gold_label(bank.gold)
	set_stolen_label(stolen.stolen_gold)

func set_gold_label(gold) -> void:
	$Gold_Quota/GoldLabel.text = "Gold: " + str(gold)

func set_stolen_label(gold) -> void:
	$HumanStole/StolenLabel.text  = "Stolen from Humans: " + str(gold)

func _on_spike_trap_pressed() -> void:
	trap_select.emit(spike_trap)
