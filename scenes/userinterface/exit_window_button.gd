extends Button

@onready var tut_1_texture_rect: TextureRect = $"../../Tut1TextureRect"
@onready var tut_2_texture_rect: TextureRect = $"../../Tut2TextureRect"
@onready var tutorial_panel_container: PanelContainer = $"../../../.."

func _on_pressed() -> void:
	tut_1_texture_rect.visible = true
	tut_2_texture_rect.visible = false
	tutorial_panel_container.visible = false
