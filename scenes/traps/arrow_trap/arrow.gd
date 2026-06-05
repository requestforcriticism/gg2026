extends Area3D

@export var direction:Vector3
@export var damage := 10
@export var speed := 5.0

func _physics_process(delta: float) -> void:
	position += direction * delta * speed

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("enemy"):
		if area.get_parent().items_purchased[1]:
			area.get_parent().current_health -= floori(damage/2)
			area.get_parent().damage_taken[1] += floori(damage/2)
			area.get_parent().damage_taken[2] += (1.0-area.get_parent().slowed_perc) * damage/2.0
		else:
			area.get_parent().current_health -= damage
			area.get_parent().damage_taken[1] += damage
			area.get_parent().damage_taken[2] += (1.0-area.get_parent().slowed_perc) * damage
	
	queue_free()
	

func _on_body_entered(body: Node3D) -> void:
	queue_free()
