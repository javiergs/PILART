extends CanvasLayer

var is_paused: bool = false

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		self.is_paused = !is_paused

