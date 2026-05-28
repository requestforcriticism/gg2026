extends PathFollow3D

@export var ability_cost := 10
@export var damage := 15
@export var speed := 5.0

var holder = false

func _ready() -> void:
	progress_ratio = 1.0
	if holder:
		$AnimationPlayer.play("holder")	

func _physics_process(delta: float) -> void:
	progress -= delta * speed
	if progress_ratio == 0.0:
		queue_free()

func _on_area_3d_area_entered(area: Area3D) -> void:
	area.get_parent().current_health -= damage
