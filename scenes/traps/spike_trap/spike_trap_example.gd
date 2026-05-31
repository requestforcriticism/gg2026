extends "res://scenes/traps/spike_trap/spike_trap_base.gd"

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var holder := false
var spot_avail := false

func _ready() -> void:
	if holder:
		$AnimationPlayer.play("holder")
	elif spot_avail:
		$AnimationPlayer.play("spot_avail")
