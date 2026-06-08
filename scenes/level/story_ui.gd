extends CanvasLayer

@onready var level: Node3D = $".."
@export var words_label: Label
@onready var story_ui_2: CanvasLayer = $"."

@export var Start_Game_dialogue_lines: Array[String] = ["Hi","How are you?", "Bye"]



var dialogue_index: int = 0

var talking := false

#func _ready() -> void:
	#get_tree().paused = true

func _process(delta: float) -> void:
	if talking:
		if Input.is_action_just_pressed("click"):
			if dialogue_index < Start_Game_dialogue_lines.size():
				story_ui_2.visible = true
				get_tree().paused = true
			
				words_label.text = Start_Game_dialogue_lines[dialogue_index]
				dialogue_index += 1
				print("here")
				print(get_tree().paused)
			else:
				story_ui_2.visible = false
				#get_tree().paused = false
				dialogue_index = 0
	else:
		dialogue_index = 0
