extends "res://scenes/traps/arrow_trap/arrow_trap_base.gd"

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var holder := false
var spot_avail := false

func _ready() -> void:
	if holder:
		animation_player.play("holder")
	elif spot_avail:
		animation_player.play("spot_avail")
