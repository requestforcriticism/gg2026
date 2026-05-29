extends "res://scenes/abilities/Boulder/boulder_ability_base.gd"

var holder := false
var spot_avail := false
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	progress_ratio = 1.0
	printt(holder,spot_avail)

	if holder:
		animation_player.play("holder")
	elif spot_avail:
		animation_player.play("spot_avail")

func _physics_process(delta: float) -> void:
	progress -= delta * speed
	#if holder && animation_player.current_animation != "holder":
		#animation_player.stop()
		#animation_player.play("holder")
	#elif spot_avail && $AnimationPlayer.current_animation != "spot_avail":
		#$AnimationPlayer.stop()
		#$AnimationPlayer.play("spot_avail")
