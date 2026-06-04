extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var speed_mult :float = 1

func mine_gold() -> void:
	animation_player.play("got_gold",-1,speed_mult)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "got_gold":
		animation_player.play("RESET")
