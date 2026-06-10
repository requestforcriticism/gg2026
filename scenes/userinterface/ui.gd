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
@onready var bankandquota = get_tree().get_first_node_in_group("bankandquota")
@onready var stolen = get_tree().get_first_node_in_group("enemy_camp")
@onready var gridmap = get_tree().get_first_node_in_group("gridmap")
@onready var level = get_tree().get_first_node_in_group("level")

@onready var story_ui_2: CanvasLayer = $StoryUI2
@onready var spike_trapinfo: Node3D = $trap_info/SpikeTrapinfo
@onready var arrow_trap_baseinfo: Node3D = $trap_info/ArrowTrapBaseinfo
@onready var mud_trapinfo: Node3D = $trap_info/MudTrapinfo
@onready var boulder_ability_baseinfo: PathFollow3D = $trap_info/BoulderAbilityBaseinfo
@onready var dirt_block_ability_baseinfo: Node3D = $trap_info/DirtBlock_ability_baseinfo
@onready var spikecost_label: Label = $TrapAbilityOption/TrapOptions/SpikeTrapContainer/SpikeTrapButton/MarginContainer/CoinCost/spikecostLabel
@onready var arrowcost_label: Label = $TrapAbilityOption/TrapOptions/ArrowTrapContainer/ArrowTrapButton/MarginContainer/CoinCost/arrowcostLabel
@onready var mudcost_label: Label = $TrapAbilityOption/TrapOptions/MudTrapContainer/MudTrapButton/MarginContainer/CoinCost/mudcostLabel

@onready var boulder_ability_cooldown_timer: Timer = $TrapAbilityOption/AbilityOptions/BoulderAbilityContainer/BoulderAbilityCooldownTimer
@onready var bouldercooldown_label: Label = $TrapAbilityOption/AbilityOptions/BoulderAbilityContainer/BoulderAbilityButton/MarginContainer/bouldercooldownLabel
@onready var wall_ability_cooldown_timer: Timer = $TrapAbilityOption/AbilityOptions/WallAbilityContainer/WallAbilityCooldownTimer
@onready var wallcooldown_label: Label = $TrapAbilityOption/AbilityOptions/WallAbilityContainer/WallAbilityButton/MarginContainer/wallcooldownLabel

@onready var gold_label: Label = $Gold_Quota/GoldLabel
@onready var quota_label: Label = $Gold_Quota/QuotaLabel
@onready var stolen_label: Label = $HumanStole/StolenLabel

@onready var spike_info_container: PanelContainer = $TrapAbilityOption/SpikeInfoContainer
@onready var arrow_info_container: PanelContainer = $TrapAbilityOption/ArrowInfoContainer
@onready var mud_info_container: PanelContainer = $TrapAbilityOption/MudInfoContainer
@onready var boulder_info_container: PanelContainer = $TrapAbilityOption/BoulderInfoContainer
@onready var wall_info_container: PanelContainer = $TrapAbilityOption/WallInfoContainer

@onready var boulder_ability_container: VBoxContainer = $TrapAbilityOption/AbilityOptions/BoulderAbilityContainer
@onready var wall_ability_container: VBoxContainer = $TrapAbilityOption/AbilityOptions/WallAbilityContainer
@onready var spike_trap_container: VBoxContainer = $TrapAbilityOption/TrapOptions/SpikeTrapContainer
@onready var arrow_trap_container: VBoxContainer = $TrapAbilityOption/TrapOptions/ArrowTrapContainer
@onready var mud_trap_container: VBoxContainer = $TrapAbilityOption/TrapOptions/MudTrapContainer

@onready var tab_layer_info: HBoxContainer = $TabLayerInfo

var ability_cooldown := 15
var boulder_cooldown :int
var boulder_ready :bool
var wall_cooldown :int
var wall_ready :bool
var holding_trap: Node3D

func _ready() -> void:
	set_gold_label(bankquota.gold)
	set_stolen_label(stolen.stolen_gold)
	set_quota_label(bankquota.earned_for_quota, bankquota.quota[level.layer_unlocked-1])
	spikecost_label.text = str(spike_trapinfo.trap_cost[0])
	arrowcost_label.text = str(arrow_trap_baseinfo.trap_cost[0])
	mudcost_label.text = str(mud_trapinfo.trap_cost[0])
	boulder_ready = true
	wall_ready = true
	boulder_cooldown = ability_cooldown
	bouldercooldown_label.visible = false
	wall_cooldown = ability_cooldown
	wallcooldown_label.visible = false

func _process(delta: float) -> void:
	check_if_won()

@onready var lose_game_audio_stream_player: AudioStreamPlayer = $LoseGameAudioStreamPlayer
@onready var win_game_audio_stream_player: AudioStreamPlayer = $WinGameAudioStreamPlayer

func check_if_lost() -> void:
	printt(bankandquota.quota[level.layer_unlocked-1],bankandquota.earned_for_quota)
	story_ui_2.lost_game_dialogue()
	lose_game_audio_stream_player.play()
	get_tree().paused = true

func check_if_won() -> void:
	if level.layer_unlocked == level.layers:
		if bankandquota.earned_for_quota >= bankandquota.quota[level.layer_unlocked-1]:
			story_ui_2.won_game_dialogue()
			win_game_audio_stream_player.play()

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

@onready var spike_level_value_label: Label = $TrapAbilityOption/SpikeInfoContainer/MarginContainer/VBoxContainer/GridContainer/spikeLevelValueLabel
@onready var spikecost_cd_value_label: Label = $TrapAbilityOption/SpikeInfoContainer/MarginContainer/VBoxContainer/GridContainer/spikecostCDValueLabel
@onready var spike_damage_passive_value_label: Label = $TrapAbilityOption/SpikeInfoContainer/MarginContainer/VBoxContainer/GridContainer/spikeDamagePassiveValueLabel
@onready var spike_damage_thrustvalue_label: Label = $TrapAbilityOption/SpikeInfoContainer/MarginContainer/VBoxContainer/GridContainer/spikeDamageThrustvalueLabel
@onready var spike_trap_button: Button = $TrapAbilityOption/TrapOptions/SpikeTrapContainer/SpikeTrapButton

func _on_spike_trap_pressed() -> void:
	if !story_ui_2.talking:
		close_info_windows()
		trap_ability_select_audio_stream_player.play()
		set_spike_info(1) # 1 is base level
		spike_info_container.visible= true
		
		var temp_trap = spike_trap.instantiate()
		if bankquota.gold >= temp_trap.trap_cost[0]:
			trap_select.emit(spike_trap, spike_trap_example)
		else:
			flash_button(spike_trap_button)
		temp_trap.queue_free()

func set_spike_info(level:int) -> void:
	spike_level_value_label.text = str(level)
	spikecost_cd_value_label.text = str(spike_trapinfo.trap_cost[level-1])
	spike_damage_passive_value_label.text = str(spike_trapinfo.passive_spike_buildup_damage[level-1]) + " / 0.1 Sec"
	spike_damage_thrustvalue_label.text = str(spike_trapinfo.spike_thrust_damage[level-1])

@onready var arrow_level_value_label: Label = $TrapAbilityOption/ArrowInfoContainer/MarginContainer/VBoxContainer/GridContainer/ArrowLevelValueLabel
@onready var arrowcost_cd_value_label: Label = $TrapAbilityOption/ArrowInfoContainer/MarginContainer/VBoxContainer/GridContainer/ArrowcostCDValueLabel
@onready var arrow_fire_rate_value_label: Label = $TrapAbilityOption/ArrowInfoContainer/MarginContainer/VBoxContainer/GridContainer/ArrowFireRateValueLabel
@onready var arrow_damagevalue_label: Label = $TrapAbilityOption/ArrowInfoContainer/MarginContainer/VBoxContainer/GridContainer/ArrowDamagevalueLabel
@onready var arrow_trap_button: Button = $TrapAbilityOption/TrapOptions/ArrowTrapContainer/ArrowTrapButton

func _on_arrow_trap_button_pressed() -> void:
	if !story_ui_2.talking:
		if level.layer_unlocked > 1:
			close_info_windows()
			trap_ability_select_audio_stream_player.play()
			set_arrow_info(1) # 1 is base level
			arrow_info_container.visible = true
			
			var temp_trap = arrow_trap.instantiate()
			if bankquota.gold >= temp_trap.trap_cost[0]:
				trap_select.emit(arrow_trap, arrow_trap_example)
			else:
				flash_button(arrow_trap_button)
			temp_trap.queue_free()

func set_arrow_info(level:int) -> void:
	arrow_level_value_label.text = str(level)
	arrowcost_cd_value_label.text = str(arrow_trap_baseinfo.trap_cost[level-1])
	arrow_fire_rate_value_label.text = str(1/arrow_trap_baseinfo.arrow_fire_rate[level-1]) + " Shots / Sec"
	arrow_damagevalue_label.text = str(arrow_trap_baseinfo.arrow_damage[level-1])

@onready var mud_level_value_label: Label = $TrapAbilityOption/MudInfoContainer/MarginContainer/VBoxContainer/GridContainer/MudLevelValueLabel
@onready var mudcost_cd_value_label: Label = $TrapAbilityOption/MudInfoContainer/MarginContainer/VBoxContainer/GridContainer/MudcostCDValueLabel
@onready var mud_speed_reduce_value_label: Label = $TrapAbilityOption/MudInfoContainer/MarginContainer/VBoxContainer/GridContainer/MudSpeedReduceValueLabel
@onready var mud_trap_button: Button = $TrapAbilityOption/TrapOptions/MudTrapContainer/MudTrapButton

func _on_mud_trap_button_pressed() -> void:
	if !story_ui_2.talking:
		if level.layer_unlocked > 2:
			close_info_windows()
			trap_ability_select_audio_stream_player.play()
			set_mud_info(1) # 1 is base level
			mud_info_container.visible = true
			
			var temp_trap = mud_trap.instantiate()
			if bankquota.gold >= temp_trap.trap_cost[0]:
				trap_select.emit(mud_trap, mud_trap_example)
			else:
				flash_button(mud_trap_button)
			temp_trap.queue_free()
	
func set_mud_info(level:int) -> void:
	mud_level_value_label.text = str(level)
	mudcost_cd_value_label.text = str(mud_trapinfo.trap_cost[level-1])
	mud_speed_reduce_value_label.text = str(int(100*mud_trapinfo.speed_reduce_percent[level-1])) +"%"

@onready var boulder_level_value_label: Label = $TrapAbilityOption/BoulderInfoContainer/MarginContainer/VBoxContainer/GridContainer/BoulderLevelValueLabel
@onready var bouldercost_cd_value_label: Label = $TrapAbilityOption/BoulderInfoContainer/MarginContainer/VBoxContainer/GridContainer/BouldercostCDValueLabel
@onready var boulder_damage_value_label: Label = $TrapAbilityOption/BoulderInfoContainer/MarginContainer/VBoxContainer/GridContainer/BoulderDamageValueLabel
@onready var boulder_stun_value_label: Label = $TrapAbilityOption/BoulderInfoContainer/MarginContainer/VBoxContainer/GridContainer/BoulderStunValueLabel
@onready var boulder_ability_button: Button = $TrapAbilityOption/AbilityOptions/BoulderAbilityContainer/BoulderAbilityButton

func _on_boulder_ability_button_pressed() -> void:
	if !story_ui_2.talking:
		if level.layer_unlocked > 1:
			close_info_windows()
			trap_ability_select_audio_stream_player.play()
			set_boulder_info(1) # 1 is base level
			boulder_info_container.visible = true
			if boulder_ready:
				ability_select.emit(boulder_ability, boulder_ability_example)
			else:
				flash_button(boulder_ability_button)

func set_boulder_info(level:int) -> void:
	bouldercost_cd_value_label.text = str(ability_cooldown) + " Sec"
	boulder_damage_value_label.text = str(boulder_ability_baseinfo.damage[0]) #only one value

@onready var cost_cd_value_label: Label = $TrapAbilityOption/WallInfoContainer/MarginContainer/VBoxContainer/GridContainer/costCDValueLabel
@onready var hp_value_label: Label = $TrapAbilityOption/WallInfoContainer/MarginContainer/VBoxContainer/GridContainer/HPValueLabel
@onready var wall_ability_button: Button = $TrapAbilityOption/AbilityOptions/WallAbilityContainer/WallAbilityButton

func _on_wall_ability_button_pressed() -> void:
	if !story_ui_2.talking:
		close_info_windows()
		trap_ability_select_audio_stream_player.play()
		wall_info_container.visible = true
		if wall_ready:
			trap_select.emit(dirt_wall_ability, dirt_wall_ability_example)
		else:
			flash_button(wall_ability_button)

func set_wall_info(level:int) -> void:
	cost_cd_value_label.text = str(ability_cooldown) + " Sec"
	hp_value_label.text = str(dirt_block_ability_baseinfo.Max_HP)

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
		boulder_ability_cooldown_timer.stop()
		boulder_ready = true
		bouldercooldown_label.visible = false
		boulder_cooldown = ability_cooldown
	else:
		boulder_ability_cooldown_timer.start()

func _on_wall_ability_cooldown_timer_timeout() -> void:
	wall_cooldown -= 1
	wallcooldown_label.text = str(wall_cooldown)
	if wall_cooldown == 0:
		wall_ability_cooldown_timer.stop()
		wall_ready = true
		wallcooldown_label.visible = false
		wall_cooldown = ability_cooldown
	else:
		wall_ability_cooldown_timer.start()

func close_info_windows() -> void:
	spike_info_container.visible = false
	arrow_info_container.visible = false
	mud_info_container.visible = false
	boulder_info_container.visible = false
	wall_info_container.visible = false
	selected_spike_info_container.visible = false
	selected_arrow_info_container.visible = false
	selected_mud_info_container.visible = false

@onready var selected_spike_info_container: PanelContainer = $TrapAbilityOption/SelectedSpikeInfoContainer
@onready var selected_arrow_info_container: PanelContainer = $TrapAbilityOption/SelectedArrowInfoContainer
@onready var selected_mud_info_container: PanelContainer = $TrapAbilityOption/SelectedMudInfoContainer

func show_selected_trap(new_holding_trap: Node3D) -> void:
	holding_trap = new_holding_trap
	close_info_windows()
	if holding_trap.is_in_group("dirtblock"):
		return
	holding_trap.selected()
	if holding_trap.is_in_group("spike"):
		set_spike_upgrade_info(holding_trap)
	elif holding_trap.is_in_group("arrow"):
		set_arrow_upgrade_info(holding_trap)
	elif holding_trap.is_in_group("mud"):
		set_mud_upgrade_info(holding_trap)
	else:
		print(holding_trap," should not have been selected!")

@onready var selectedspike_level_value_label: Label = $TrapAbilityOption/SelectedSpikeInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedspikeLevelValueLabel
@onready var selectedspikecost_cd_value_label: Label = $TrapAbilityOption/SelectedSpikeInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedspikecostCDValueLabel
@onready var selectedspike_damage_passive_value_label: Label = $TrapAbilityOption/SelectedSpikeInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedspikeDamagePassiveValueLabel
@onready var selectedspike_damage_passive_value_label_2: Label = $TrapAbilityOption/SelectedSpikeInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedspikeDamagePassiveValueLabel2
@onready var selectedspike_damage_thrustvalue_label: Label = $TrapAbilityOption/SelectedSpikeInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedspikeDamageThrustvalueLabel
@onready var selectedspike_damage_thrustvalue_label_2: Label = $TrapAbilityOption/SelectedSpikeInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedspikeDamageThrustvalueLabel2
@onready var selectedspike_cost_cd_label: Label = $TrapAbilityOption/SelectedSpikeInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedspikeCostCDLabel
@onready var selected_damage_passive_label_2: Label = $TrapAbilityOption/SelectedSpikeInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedDamagePassiveLabel2
@onready var selected_damage_thrust_label_2: Label = $TrapAbilityOption/SelectedSpikeInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedDamageThrustLabel2
@onready var selectedspike_button: Button = $TrapAbilityOption/SelectedSpikeInfoContainer/MarginContainer/VBoxContainer/HBoxContainer/SelectedspikeButton
@onready var sellspike_button: Button = $TrapAbilityOption/SelectedSpikeInfoContainer/MarginContainer/VBoxContainer/HBoxContainer/SellspikeButton

func set_spike_upgrade_info(holding_trap: Node3D) -> void:
	selected_spike_info_container.visible = true
	selectedspike_level_value_label.text = str(holding_trap.trap_level+1)
	selectedspike_damage_passive_value_label.text = str(holding_trap.passive_spike_buildup_damage[holding_trap.trap_level]) + " / 0.1 Sec"
	selectedspike_damage_thrustvalue_label.text = str(holding_trap.spike_thrust_damage[holding_trap.trap_level])
	sellspike_button.text = str("Sell Trap: ",int(ceil(holding_trap.trap_cost[holding_trap.trap_level]*0.75))," Gold" ) 
	if holding_trap.trap_level < 2:
		selectedspike_button.visible = true
		selectedspike_cost_cd_label.visible = true
		selected_damage_passive_label_2.visible = true
		selected_damage_thrust_label_2.visible = true
		selectedspikecost_cd_value_label.visible = true
		selectedspikecost_cd_value_label.text = str(holding_trap.trap_cost[holding_trap.trap_level+1])
		selectedspike_damage_passive_value_label_2.visible = true
		selectedspike_damage_passive_value_label_2.text = str(holding_trap.passive_spike_buildup_damage[holding_trap.trap_level+1]) + " / 0.1 Sec"
		selectedspike_damage_thrustvalue_label_2.visible = true
		selectedspike_damage_thrustvalue_label_2.text = str(holding_trap.spike_thrust_damage[holding_trap.trap_level+1])
	else:
		selectedspike_button.visible = false
		selectedspike_cost_cd_label.visible = false
		selected_damage_passive_label_2.visible = false
		selected_damage_thrust_label_2.visible = false
		selectedspikecost_cd_value_label.visible = false
		selectedspike_damage_passive_value_label_2.visible = false
		selectedspike_damage_thrustvalue_label_2.visible = false

@onready var selected_arrow_level_value_label: Label = $TrapAbilityOption/SelectedArrowInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedArrowLevelValueLabel
@onready var selected_arrowcost_cd_value_label: Label = $TrapAbilityOption/SelectedArrowInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedArrowcostCDValueLabel
@onready var selected_arrow_fire_rate_value_label: Label = $TrapAbilityOption/SelectedArrowInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedArrowFireRateValueLabel
@onready var selected_arrow_fire_rate_value_label_2: Label = $TrapAbilityOption/SelectedArrowInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedArrowFireRateValueLabel2
@onready var selected_arrow_damagevalue_label: Label = $TrapAbilityOption/SelectedArrowInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedArrowDamagevalueLabel
@onready var selected_arrow_damagevalue_label_2: Label = $TrapAbilityOption/SelectedArrowInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedArrowDamagevalueLabel2
@onready var selected_arrow_cost_cd_label: Label = $TrapAbilityOption/SelectedArrowInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedArrowCostCDLabel
@onready var selected_arrow_fire_rate_label_2: Label = $TrapAbilityOption/SelectedArrowInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedArrowFireRateLabel2
@onready var selected_arrow_damage_label_2: Label = $TrapAbilityOption/SelectedArrowInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedArrowDamageLabel2
@onready var selected_arrow_button: Button = $TrapAbilityOption/SelectedArrowInfoContainer/MarginContainer/VBoxContainer/HBoxContainer/SelectedArrowButton
@onready var sell_arrow_button: Button = $TrapAbilityOption/SelectedArrowInfoContainer/MarginContainer/VBoxContainer/HBoxContainer/SellArrowButton

func set_arrow_upgrade_info(holding_trap: Node3D) -> void:
	selected_arrow_info_container.visible = true
	selected_arrow_level_value_label.text = str(holding_trap.trap_level+1)
	selected_arrow_fire_rate_value_label.text = str(1/holding_trap.arrow_fire_rate[holding_trap.trap_level]) + " Shots / Sec"
	selected_arrow_damagevalue_label.text = str(holding_trap.arrow_damage[holding_trap.trap_level])
	sell_arrow_button.text = str("Sell Trap: ",int(ceil(holding_trap.trap_cost[holding_trap.trap_level]*0.75))," Gold" ) 
	if holding_trap.trap_level < 2:
		selected_arrow_button.visible = true
		selected_arrow_cost_cd_label.visible = true
		selected_arrow_fire_rate_label_2.visible = true
		selected_arrow_damage_label_2.visible = true
		selected_arrowcost_cd_value_label.visible = true
		selected_arrowcost_cd_value_label.text = str(holding_trap.trap_cost[holding_trap.trap_level+1])
		selected_arrow_fire_rate_value_label_2.visible = true
		selected_arrow_fire_rate_value_label_2.text = str(1/holding_trap.arrow_fire_rate[holding_trap.trap_level+1]) + " Shots / Sec"
		selected_arrow_damagevalue_label_2.visible = true
		selected_arrow_damagevalue_label_2.text = str(holding_trap.arrow_damage[holding_trap.trap_level+1])
	else:
		selected_arrow_button.visible = false
		selected_arrow_cost_cd_label.visible = false
		selected_arrow_fire_rate_label_2.visible = false
		selected_arrow_damage_label_2.visible = false
		selected_arrowcost_cd_value_label.visible = false
		selected_arrow_fire_rate_value_label_2.visible = false
		selected_arrow_damagevalue_label_2.visible = false

@onready var selected_mud_level_value_label: Label = $TrapAbilityOption/SelectedMudInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedMudLevelValueLabel
@onready var selected_mudcost_cd_value_label: Label = $TrapAbilityOption/SelectedMudInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedMudcostCDValueLabel
@onready var selected_mud_speed_reduce_value_label: Label = $TrapAbilityOption/SelectedMudInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedMudSpeedReduceValueLabel
@onready var selected_mud_speed_reduce_value_label_2: Label = $TrapAbilityOption/SelectedMudInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedMudSpeedReduceValueLabel2
@onready var selected_mud_cost_cd_label: Label = $TrapAbilityOption/SelectedMudInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedMudCostCDLabel
@onready var selected_mud_speed_reduce_label_2: Label = $TrapAbilityOption/SelectedMudInfoContainer/MarginContainer/VBoxContainer/GridContainer/SelectedMudSpeedReduceLabel2
@onready var selected_mud_button: Button = $TrapAbilityOption/SelectedMudInfoContainer/MarginContainer/VBoxContainer/HBoxContainer/SelectedMudButton
@onready var sell_mud_button: Button = $TrapAbilityOption/SelectedMudInfoContainer/MarginContainer/VBoxContainer/HBoxContainer/SellMudButton

func set_mud_upgrade_info(holding_trap: Node3D):
	selected_mud_info_container.visible = true
	selected_mud_level_value_label.text = str(holding_trap.trap_level+1)
	selected_mud_speed_reduce_value_label.text = str(int(100*holding_trap.speed_reduce_percent[holding_trap.trap_level])) +"%"
	sell_mud_button.text = str("Sell Trap: ",int(ceil(holding_trap.trap_cost[holding_trap.trap_level]*0.75))," Gold" ) 
	if holding_trap.trap_level < 2:
		selected_mud_cost_cd_label.visible = true
		selected_mud_speed_reduce_label_2.visible = true
		selected_mud_button.visible = true
		selected_mudcost_cd_value_label.visible = true
		selected_mudcost_cd_value_label.text = str(holding_trap.trap_cost[holding_trap.trap_level+1])
		selected_mud_speed_reduce_value_label_2.visible = true
		selected_mud_speed_reduce_value_label_2.text = str(int(100*holding_trap.speed_reduce_percent[holding_trap.trap_level+1])) +"%"
	else:
		selected_mud_cost_cd_label.visible = false
		selected_mud_speed_reduce_label_2.visible = false
		selected_mud_button.visible = false
		selected_mudcost_cd_value_label.visible = false
		selected_mud_speed_reduce_value_label_2.visible = false

func _on_button_pressed() -> void:
	if holding_trap:
		if holding_trap.trap_level < 2:
			if bankquota.gold >= holding_trap.trap_cost[holding_trap.trap_level+1]:
				bankquota.gold -= holding_trap.trap_cost[holding_trap.trap_level+1]
				holding_trap.upgrade()
				show_selected_trap(holding_trap)
			else:
				selectedspike_button.self_modulate = Color.RED
				selected_arrow_button.self_modulate = Color.RED
				selected_mud_button.self_modulate = Color.RED
				await get_tree().create_timer(0.05).timeout
				selectedspike_button.self_modulate = Color.WHITE
				selected_arrow_button.self_modulate = Color.WHITE
				selected_mud_button.self_modulate = Color.WHITE

func _on_sell_button_pressed() -> void:
	if holding_trap:
		bankquota.gold += ceil(holding_trap.trap_cost[holding_trap.trap_level]*0.75)
		gridmap.set_cell_item(gridmap.local_to_map(holding_trap.position), 0)
		holding_trap.queue_free()
		close_info_windows()

@onready var trap_ability_select_audio_stream_player: AudioStreamPlayer = $TrapAbilitySelectAudioStreamPlayer
@onready var wrong_ability_trap_select_audio_stream_player: AudioStreamPlayer = $WrongAbilityTrapSelectAudioStreamPlayer

func flash_button(button_2_flash: Button) -> void:
	button_2_flash.self_modulate = Color.RED
	await get_tree().create_timer(0.05).timeout
	button_2_flash.self_modulate = Color.WHITE
	wrong_ability_trap_select_audio_stream_player.play()

func unlock_trapabilities() -> void:
	if level.layer_unlocked > 1:
		tab_layer_info.visible = true
		boulder_ability_container.visible = true
		arrow_trap_container.visible = true
	if level.layer_unlocked > 2:
		mud_trap_container.visible = true

@onready var game_end: PanelContainer = $GameEnd
@onready var win_lose_label: Label = $GameEnd/MarginContainer/VBoxContainer/WinLoseLabel

func end_game(result:String) -> void:
	if result == "won":
		win_lose_label.text = str("You Won")
	elif result == "lost":
		win_lose_label.text = str("You Lost")
	game_end.visible = true
