extends Node3D

var Gold_in_Bag:
	set(gold_in):
		Gold_in_Bag = gold_in

func _on_dropped_bag_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("enemy"):
		var gold_space_left :int = area.get_parent().max_gold_capacity - area.get_parent().gold_in_bag
		if gold_space_left != 0:
			area.get_parent().gold_in_bag += min(gold_space_left,Gold_in_Bag)
			if area.get_parent().gold_in_bag > area.get_parent().max_gold_capacity/2:
				area.get_parent().leave()
			Gold_in_Bag -= min(gold_space_left,Gold_in_Bag)
			if Gold_in_Bag < 1:
				queue_free()
	
		#Add gold to enemy bad upto cap.  If all Gold_in_Bag is gone, queue_free().  Either way, send enemy_back.
