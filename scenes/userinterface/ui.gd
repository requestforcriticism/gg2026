extends MarginContainer

signal trap_select(T2d)
signal ability_select(A2d)

@export var spike_trap: PackedScene
@export var spike_trap_example: PackedScene
@export var arrow_trap: PackedScene
@export var arrow_trap_example: PackedScene
@export var mud_trap: PackedScene
@export var mud_trap_example: PackedScene
@export var boulder_ability: PackedScene
@export var boulder_ability_example: PackedScene
@export var dirt_wall_ability: PackedScene
@export var dirt_wall_ability_example: PackedScene

@onready var bankquota = get_tree().get_first_node_in_group("bankandquota")
@onready var quota = get_tree().get_first_node_in_group("quota")
@onready var stolen = get_tree().get_first_node_in_group("enemy_camp")



@onready var boulder_ability_cooldown_timer: Timer = $TrapAbilityOption/AbilityOptions/BoulderAbility/BoulderAbilityCooldownTimer
@onready var bouldercooldown_label: Label = $TrapAbilityOption/AbilityOptions/BoulderAbility/BoulderAbilityButton/MarginContainer/bouldercooldownLabel
@onready var wall_ability_cooldown_timer: Timer = $TrapAbilityOption/AbilityOptions/WallAbility/WallAbilityCooldownTimer
@onready var wallcooldown_label: Label = $TrapAbilityOption/AbilityOptions/WallAbility/WallAbilityButton/MarginContainer/wallcooldownLabel

@onready var gold_label: Label = $Gold_Quota/GoldLabel
@onready var quota_label: Label = $Gold_Quota/QuotaLabel
@onready var stolen_label: Label = $HumanStole/StolenLabel

var ability_cooldown := 15.0
var boulder_cooldown :int
var boulder_ready :bool
var wall_cooldown :int
var wall_ready :bool

func _ready() -> void:
	set_gold_label(bankquota.gold)
	set_stolen_label(stolen.stolen_gold)
	set_quota_label(bankquota.earned_for_quota, bankquota.current_quota)
	boulder_ready = true
	wall_ready = true
	boulder_cooldown = ability_cooldown
	bouldercooldown_label.visible = false
	wall_cooldown = ability_cooldown
	wallcooldown_label.visible = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("num1"):
			_on_spike_trap_pressed()
		elif Input.is_action_just_pressed("num2"):
			_on_arrow_trap_button_pressed()
		elif Input.is_action_just_pressed("num3"):
			_on_mud_trap_button_pressed()
		elif Input.is_action_just_pressed("num4"):
			_on_boulder_ability_button_pressed()
		elif Input.is_action_just_pressed("num5"):
			_on_wall_ability_button_pressed()

func set_gold_label(gold) -> void:
	$Gold_Quota/GoldLabel.text = str(gold)

func set_quota_label(earned_for_quota, current_quota) -> void:
	$Gold_Quota/QuotaLabel.text = str(earned_for_quota) + "/" + str(current_quota)

func set_stolen_label(gold) -> void:
	$HumanStole/StolenLabel.text  = "Stolen from Humans: " + str(gold)

func _on_spike_trap_pressed() -> void:
	trap_select.emit(spike_trap, spike_trap_example)

func _on_arrow_trap_button_pressed() -> void:
	trap_select.emit(arrow_trap, arrow_trap_example)

func _on_mud_trap_button_pressed() -> void:
	trap_select.emit(mud_trap, mud_trap_example)

func _on_boulder_ability_button_pressed() -> void:
	if boulder_ready:
		ability_select.emit(boulder_ability, boulder_ability_example)

func _on_wall_ability_button_pressed() -> void:
	if wall_ready:
		trap_select.emit(dirt_wall_ability, dirt_wall_ability_example)

func start_cooldown_timer(type:String) -> void:
	if type == "dirtblock":
		wall_ready = false
		wallcooldown_label.visible = true
		wallcooldown_label.text = str(wall_cooldown)
		wall_ability_cooldown_timer.start()
	elif type == "boulder":
		boulder_ready = false
		bouldercooldown_label.visible = true
		bouldercooldown_label.text = str(boulder_cooldown)
		boulder_ability_cooldown_timer.start()

func _on_boulder_ability_colldown_timer_timeout() -> void:
	boulder_cooldown -= 1
	bouldercooldown_label.text = str(boulder_cooldown)
	if boulder_cooldown == 0:
		boulder_ready = true
		bouldercooldown_label.visible = false
	else:
		boulder_ability_cooldown_timer.start()

func _on_wall_ability_cooldown_timer_timeout() -> void:
	wall_cooldown -= 1
	wallcooldown_label.text = str(wall_cooldown)
	if wall_cooldown == 0:
		wall_ready = true
		wallcooldown_label.visible = false
	else:
		wall_ability_cooldown_timer.start()
