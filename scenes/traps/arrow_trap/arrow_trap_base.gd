extends Node3D

@export var trap_cost := 50
@export var arrow_scene: PackedScene
@export var arrow_damage := 10

var direction := Vector3 (0,0,1)
var mark_options: Array
var i := 0
var mark_options_size

@onready var shoot_timer: Timer = $ShootTimer

func _ready() -> void:
	mark_options = [$Wall/hole/Marker3D,$Wall/hole2/Marker3D,$Wall/hole3/Marker3D,$Wall/hole4/Marker3D,$Wall/hole5/Marker3D,$Wall2/hole/Marker3D,$Wall2/hole2/Marker3D,$Wall2/hole3/Marker3D,$Wall2/hole4/Marker3D,$Wall2/hole5/Marker3D] 
	mark_options.shuffle()
	#mark_options = [$Wall/hole/Marker3D,$Wall2/hole/Marker3D] 

	mark_options_size = mark_options.size()
	shoot_timer.start()

func _on_shoot_timer_timeout() -> void:
	var new_arrow = arrow_scene.instantiate()
	new_arrow.direction = direction.rotated(Vector3(0, 1, 0), mark_options[i].rotation.y)
	new_arrow.position = mark_options[i].position
	new_arrow.rotation.y += mark_options[i].rotation.y
	add_child(new_arrow)
	i = posmod(i+1,mark_options_size)
	#print(i)
	
