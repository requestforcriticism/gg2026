extends PathFollow3D

@export var speed := 2.0
@export var max_health := 50
@export var mine_rate := 1.0
@export var max_gold_capacity := 25

var current_health: int:
	set(health_in):
		current_health = health_in
		if current_health < 1:
			queue_free()

func _ready() -> void:
	current_health = max_health
	
func _physics_process(delta: float) -> void:
	progress += delta * speed
	if progress_ratio == 1.0:
		queue_free()
		# Need logic for mining at a vein if progress reaches 1.0
