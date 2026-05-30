extends Area3D

@export var direction:Vector3
@export var damage := 10
@export var speed := 5.0

func _physics_process(delta: float) -> void:
	position += direction * delta * speed

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("enemy"):
		area.get_parent().current_health -= damage
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	queue_free()
