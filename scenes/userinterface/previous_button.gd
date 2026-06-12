extends Button

@onready var tut_1_texture_rect: TextureRect = $"../../Tut1TextureRect"
@onready var tut_2_texture_rect: TextureRect = $"../../Tut2TextureRect"


func _on_pressed() -> void:
	if tut_1_texture_rect.visible:
		tut_1_texture_rect.visible = false
		tut_2_texture_rect.visible = true
	else:
		tut_1_texture_rect.visible = true
		tut_2_texture_rect.visible = false
