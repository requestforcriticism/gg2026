extends Node3D

var Gold_in_Bag := 0

func _on_dropped_bag_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("enemy"):
		area.get_parent().max_gold_capacity
		#Add gold to enemy bad upto cap.  If all Gold_in_Bag is gone, queue_free().  Either way, send enemy_back.
