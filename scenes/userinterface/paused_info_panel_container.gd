extends PanelContainer

@onready var paused_panel_container: PanelContainer = $"../PausedPanelContainer"

func _process(delta: float) -> void:
	if paused_panel_container.visible:
		visible = true
	else:
		visible = false
