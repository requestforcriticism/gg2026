extends PathFollow3D

@export var ability_cost := 10
@export var damage := 15
@export var speed := 5.0

var holder = false
var spot_avail = false
var active = false

func _ready() -> void:
	progress_ratio = 1.0
	if holder:
		$AnimationPlayer.play("holder")	

func _physics_process(delta: float) -> void:
	progress -= delta * speed
	if !spot_avail:
		if progress_ratio == 0.0:
			queue_free()
	
	if holder && $AnimationPlayer.current_animation != "holder":
		$AnimationPlayer.stop()
		$AnimationPlayer.play("holder")
	elif spot_avail && $AnimationPlayer.current_animation != "spot_avail":
		$AnimationPlayer.stop()
		$AnimationPlayer.play("spot_avail")
	elif active && $AnimationPlayer.current_animation != "spin":
		$AnimationPlayer.stop()
		$AnimationPlayer.play("spin")

func _on_area_3d_area_entered(area: Area3D) -> void:
	area.get_parent().current_health -= damage
