extends "res://scenes/traps/spike_trap/spike_trap_base.gd"

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var holder := false
var spot_avail := false

func _ready() -> void:
	if holder:
		$AnimationPlayer.play("holder")
	elif spot_avail:
		$AnimationPlayer.play("spot_avail")

#
#func _physics_process(delta: float) -> void:
	#if holder && !$AnimationPlayer.current_animation == "holder":
		#$AnimationPlayer.stop()
		#$AnimationPlayer.play("holder")
		#
	#elif spot_avail && !$AnimationPlayer.current_animation == "spot_avail":
		#$AnimationPlayer.stop()
		#$AnimationPlayer.play("spot_avail")
