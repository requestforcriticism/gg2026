extends "res://scenes/traps/mud_trap/mud_trap_base.gd"

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var holder := false
var spot_avail := false

func _ready() -> void:
	if holder:
		$AnimationPlayer.play("holder")
	elif spot_avail:
		$AnimationPlayer.play("spot_avail")
