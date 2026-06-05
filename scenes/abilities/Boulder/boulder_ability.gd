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
	if area.is_in_group("enemy"):
		area.get_parent().get_stunned(stun_time[0])
		if area.get_parent().items_purchased[1]:
			area.get_parent().current_health -= floori(damage[0]/2)
			area.get_parent().damage_taken[3] += floori(damage[0]/2)
			area.get_parent().damage_taken[2] += (1.0-area.get_parent().slowed_perc) * damage[0]/2.0
		else:
			area.get_parent().current_health -= damage[0]
			area.get_parent().damage_taken[3] += damage[0]
			area.get_parent().damage_taken[2] += (1.0-area.get_parent().slowed_perc) * damage[0]
	
	#area.get_parent().current_health -= damage
		
	
