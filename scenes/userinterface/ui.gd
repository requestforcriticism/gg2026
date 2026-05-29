extends MarginContainer

signal trap_select(T2d)
signal ability_select(A2d)

@export var spike_trap: PackedScene
@export var spike_trap_example: PackedScene
@export var arrow_trap: PackedScene
@export var boulder_ability: PackedScene
@export var boulder_ability_example: PackedScene

@onready var bankquota = get_tree().get_first_node_in_group("bankandquota")
@onready var quota = get_tree().get_first_node_in_group("quota")
@onready var stolen = get_tree().get_first_node_in_group("enemy_camp")

@onready var gold_label: Label = $Gold_Quota/GoldLabel
@onready var quota_label: Label = $Gold_Quota/QuotaLabel
@onready var stolen_label: Label = $HumanStole/StolenLabel

func _ready() -> void:
	set_gold_label(bankquota.gold)
	set_stolen_label(stolen.stolen_gold)
	set_quota_label(bankquota.earned_for_quota, bankquota.current_quota)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("num1"):
			_on_spike_trap_pressed()
		elif Input.is_action_just_pressed("num4"):
			_on_boulder_ability_button_pressed()

func set_gold_label(gold) -> void:
	$Gold_Quota/GoldLabel.text = "Gold: " + str(gold)

func set_quota_label(earned_for_quota, current_quota) -> void:
	$Gold_Quota/QuotaLabel.text = "Quota: " + str(earned_for_quota) + "/" + str(current_quota)

func set_stolen_label(gold) -> void:
	$HumanStole/StolenLabel.text  = "Stolen from Humans: " + str(gold)

func _on_spike_trap_pressed() -> void:
	trap_select.emit(spike_trap, spike_trap_example)

func _on_boulder_ability_button_pressed() -> void:
	ability_select.emit(boulder_ability, boulder_ability_example)
