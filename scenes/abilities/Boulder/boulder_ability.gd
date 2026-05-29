extends "res://scenes/abilities/Boulder/boulder_ability_base.gd"

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	progress_ratio = 1.0
	animation_player.play("spin")

func _physics_process(delta: float) -> void:
	progress -= delta * speed
	if progress_ratio == 0.0:
		queue_free()

func _on_area_3d_area_entered(area: Area3D) -> void:
	area.get_parent().current_health -= damage
	
