extends MarginContainer

signal trap_select(A3d)

@export var spike_trap: PackedScene
@export var arrow_trap: PackedScene

@onready var bank = get_tree().get_first_node_in_group("bank")

@onready var gold_label: Label = $Gold_Quota/GoldLabel
@onready var quota_label: Label = $Gold_Quota/QuotaLabel


func _ready() -> void:
	gold_label.text = "Gold: " + str(bank.gold)

func set_gold_label(gold) -> void:
	$Gold_Quota/GoldLabel.text = "Gold: " + str(gold)

func _on_spike_trap_toggled(toggled_on: bool) -> void:
	if toggled_on:
		trap_select.emit(spike_trap)
	else:
		trap_select.emit(null)
