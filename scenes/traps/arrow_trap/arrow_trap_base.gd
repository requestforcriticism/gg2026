extends Node3D

@export var trap_cost := [50,100,200]
@export var arrow_scene: PackedScene
@export var arrow_damage := [10,16,22]
@export var arrow_fire_rate := [0.5,0.4,0.3]  

var direction := Vector3 (0,0,1)
var mark_options: Array
var i := 0
var mark_options_size

var trap_level:int :
	set(level_in):
		trap_level = level_in
		update_firing_rate()

@onready var shoot_timer: Timer = $ShootTimer

func _ready() -> void:
	mark_options = [$Wall/hole/Marker3D,$Wall/hole2/Marker3D,$Wall/hole3/Marker3D,$Wall/hole4/Marker3D,$Wall/hole5/Marker3D,$Wall2/hole/Marker3D,$Wall2/hole2/Marker3D,$Wall2/hole3/Marker3D,$Wall2/hole4/Marker3D,$Wall2/hole5/Marker3D] 
	mark_options.shuffle()
	mark_options_size = mark_options.size()
	shoot_timer.start()
	shoot_timer.wait_time = arrow_fire_rate[trap_level]

func _on_shoot_timer_timeout() -> void:
	var new_arrow = arrow_scene.instantiate()
	new_arrow.direction = direction.rotated(Vector3(0, 1, 0), mark_options[i].rotation.y)
	new_arrow.position = mark_options[i].position
	new_arrow.rotation.y += mark_options[i].rotation.y
	new_arrow.damage = arrow_damage[trap_level]
	add_child(new_arrow)
	i = posmod(i+1,mark_options_size)

func update_firing_rate() -> void:
	shoot_timer.wait_time = arrow_fire_rate[trap_level]
