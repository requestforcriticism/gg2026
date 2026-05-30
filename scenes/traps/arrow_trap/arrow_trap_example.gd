extends "res://scenes/traps/arrow_trap/arrow_trap_base.gd"

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var holder := false
var spot_avail := false

func _ready() -> void:
	if holder:
		animation_player.play("holder")
	elif spot_avail:
		animation_player.play("spot_avail")
		shoot_timer.start()
	
	mark_options = [$Wall/hole/Marker3D,$Wall/hole2/Marker3D,$Wall/hole3/Marker3D,$Wall/hole4/Marker3D,$Wall/hole5/Marker3D,$Wall2/hole/Marker3D,$Wall2/hole2/Marker3D,$Wall2/hole3/Marker3D,$Wall2/hole4/Marker3D,$Wall2/hole5/Marker3D] 
	mark_options.shuffle()
	mark_options_size = mark_options.size()
	
