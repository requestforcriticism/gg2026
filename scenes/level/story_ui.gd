extends CanvasLayer


@onready var ui: MarginContainer = $".."
@onready var talking_audio_stream_player: AudioStreamPlayer = $"../TalkingAudioStreamPlayer"
@onready var raypickercamera = get_tree().get_first_node_in_group("raypickercamera")
@onready var enemymanager = get_tree().get_first_node_in_group("enemymanager")
@onready var level = get_tree().get_first_node_in_group("level")
@onready var normalmusic = get_tree().get_first_node_in_group("normalmusic")
@onready var hardmusic = get_tree().get_first_node_in_group("hardmusic")
@onready var bankquota = get_tree().get_first_node_in_group("bankandquota")

@export var words_label: Label
@onready var story_ui_2: CanvasLayer = $"."
@onready var dialague_box_texture: TextureRect = $DialagueBoxTexture
@onready var paused_panel_container: PanelContainer = $"../PausedPanelContainer"
@onready var skip_intro_panel_container: PanelContainer = $"../SkipIntroPanelContainer"
@onready var hard_mode_panel_container: Panel = $"../HardModePanelContainer"
@onready var gold_quota: GridContainer = $"../Gold_Quota"

@export var Start_Game_dialogue_gob_lines: Array[String] = ["Hi","How are you?", "Bye"]
@export var Start_Game_dialogue_human_lines: Array[String] = ["Hi","How are you?", "Bye"]
@export var Start2_Game_dialogue_gob_lines: Array[String] = ["Hi","How are you?", "Bye"]

@export var Skip_Intro_Game_dialogue_gob_lines: Array[String] = ["Hi","How are you?", "Bye"]

@export var Layer2_Game_dialogue_gob_lines: Array[String] = ["Hi","How are you?", "Bye"]
@export var Layer2b_Game_dialogue_gob_lines: Array[String] = ["Hi","How are you?", "Bye"]

@export var Lose_Game_dialogue_gob_lines: Array[String] = ["Hi","How are you?", "Bye"]
@export var Win_Game_dialogue_gob_lines: Array[String] = ["Hi","How are you?", "Bye"]

@onready var gobillionaire_image: TextureRect = $DialagueBoxTexture/GobillionaireImage
@onready var golbillionaire_name_label: Label = $DialagueBoxTexture/GolbillionaireNameLabel
@onready var human_image: TextureRect = $DialagueBoxTexture/HumanImage
@onready var human_name_label: Label = $DialagueBoxTexture/HumanNameLabel
@onready var tab_timer: Timer = $TabTimer

var dialogue_index: int = 0
var current_dialogue: Array[String]
var order:int = 1
var talking := false
var intro := false
var check_if_skipping: float = 0

func _ready() -> void:
	get_tree().paused = true
	talking = true
	intro = true
	current_dialogue = Start_Game_dialogue_gob_lines
	talking_audio_stream_player.play()
	words_label.text = current_dialogue[dialogue_index]
	dialogue_index = 1
	skip_intro_panel_container.visible = true

func _process(delta: float) -> void:
	if talking:
		if current_dialogue == Start_Game_dialogue_human_lines:
			dialague_box_texture.set_anchors_preset(Control.PRESET_CENTER_LEFT)
			gobillionaire_image.visible = false
			golbillionaire_name_label.visible = false
			human_image.visible = true
			human_name_label.visible = true
		else:
			dialague_box_texture.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
			gobillionaire_image.visible = true
			golbillionaire_name_label.visible = true
			human_image.visible = false
			human_name_label.visible = false
		story_ui_2.visible = true
		get_tree().paused = true
		if Input.is_action_just_pressed("click"):
			talking_func()

func _input(event: InputEvent) -> void:
	if !talking:
		if Input.is_action_just_pressed("pause"):
			get_tree().paused = !get_tree().paused
			if get_tree().paused:
				paused_panel_container.visible = true
			else:
				paused_panel_container.visible = false
	if talking && intro:
		if Input.is_action_pressed("pause"):
			check_if_skipping += get_process_delta_time()
			if check_if_skipping >= 0.5:
				skipping_into()
		else:
			check_if_skipping = 0.0

func skipping_into() -> void:
	if current_dialogue == Start_Game_dialogue_gob_lines:
		enemymanager.spawn_starting_base_enemy()
	current_dialogue = Skip_Intro_Game_dialogue_gob_lines
	
	gobillionaire_image.visible = true
	golbillionaire_name_label.visible = true
	human_image.visible = false
	human_name_label.visible = false
	talking = true
	intro = false
	dialogue_index = 0
	skip_intro_panel_container.visible = false
	talking_func()

func talking_func() -> void:
	if dialogue_index < current_dialogue.size():
		words_label.text = current_dialogue[dialogue_index]
		if current_dialogue ==Start_Game_dialogue_human_lines:
			talking_audio_stream_player.pitch_scale = 0.85
		else:
			talking_audio_stream_player.pitch_scale = 0.65
		talking_audio_stream_player.play()
		dialogue_index += 1
	else:
		if current_dialogue == Skip_Intro_Game_dialogue_gob_lines:
			story_ui_2.visible = false
			talking = false
			intro = false
			get_tree().paused = false
			hard_mode_panel_container.visible = true
			hard_mode_panel_container.time_4_a_hard_time()
			ui.set_gold_label(bankquota.gold)
			ui.set_quota_label(bankquota.earned_for_quota, bankquota.quota[level.layer_unlocked-1])
			gold_quota.visible = true
			hardmusic.play()
		elif current_dialogue == Win_Game_dialogue_gob_lines:
			story_ui_2.visible = false
			talking = false
			ui.end_game("won")
		elif current_dialogue == Lose_Game_dialogue_gob_lines:
			story_ui_2.visible = false
			talking = false
			ui.end_game("lost")
		elif current_dialogue == Layer2_Game_dialogue_gob_lines:
			talking = false
			raypickercamera.change_layer_stuff()
			tab_timer.start()
		elif current_dialogue == Start2_Game_dialogue_gob_lines || current_dialogue == Layer2b_Game_dialogue_gob_lines:
			story_ui_2.visible = false
			talking = false
			intro = false
			skip_intro_panel_container.visible = false
			get_tree().paused = false
			enemymanager.normal_mode()
			bankquota.quota = [30,90,825]
			ui.set_gold_label(bankquota.gold)
			ui.set_quota_label(bankquota.earned_for_quota, bankquota.quota[level.layer_unlocked-1])
			gold_quota.visible = true
			normalmusic.play()
		elif current_dialogue == Start_Game_dialogue_human_lines:
			current_dialogue = Start2_Game_dialogue_gob_lines
			dialogue_index = 0
			talking_func()
		elif current_dialogue == Start_Game_dialogue_gob_lines:
			current_dialogue = Start_Game_dialogue_human_lines
			dialogue_index = 0
		if current_dialogue == Start_Game_dialogue_human_lines && dialogue_index == 0:
			enemymanager.spawn_starting_base_enemy()
			talking_func()

func layer2_opened() -> void:
	current_dialogue = Layer2_Game_dialogue_gob_lines
	talking = true
	dialogue_index = 0
	talking_func()

func _on_tab_timer_timeout() -> void:
	current_dialogue = Layer2b_Game_dialogue_gob_lines
	talking = true
	dialogue_index = 0
	talking_func()
	level.new_layer()

func lost_game_dialogue() -> void:
	current_dialogue = Lose_Game_dialogue_gob_lines
	talking = true
	dialogue_index = 0
	talking_func()

func won_game_dialogue() -> void:
	current_dialogue = Win_Game_dialogue_gob_lines
	talking = true
	dialogue_index = 0
	talking_func()
