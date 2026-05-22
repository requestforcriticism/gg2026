extends Path3D

@export var my_path3d :Path3D

@export var max_gold: int = 1000

var current_gold: int:
	set(gold_in):
		current_gold = gold_in
		label_3d.text = "Gold: " + str(current_gold)
		var red: Color = Color.RED
		var white: Color = Color.WHITE
		label_3d.modulate = red.lerp(white,float(current_gold)/float(max_gold))
		if current_gold < 1:
			pass
			#Logic to create hold and start next layer 

@onready var label_3d: Label3D = $Label3D

func _ready() -> void:
	current_gold = max_gold

func lose_gold() -> void:
	current_gold -= 1
