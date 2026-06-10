extends Panel

@onready var hard_mode_animation_player: AnimationPlayer = $HardModeAnimationPlayer

func time_4_a_hard_time() -> void:
	hard_mode_animation_player.play("setup")
