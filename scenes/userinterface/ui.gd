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

func _on_spike_trap_pressed() -> void:
	trap_select.emit(spike_trap)
