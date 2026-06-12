extends Button

@onready var tutorial_panel_container: PanelContainer = $"../../../../TutorialPanelContainer"

func _on_pressed() -> void:
	tutorial_panel_container.visible = true
