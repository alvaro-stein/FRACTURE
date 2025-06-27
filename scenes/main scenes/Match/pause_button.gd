extends Button

const PAUSE_SCENE = preload("res://scenes/main scenes/Match/pause_menu.tscn")
var pause_menu

func _on_button_up() -> void:
	self.release_focus()
	if get_tree().paused == false:
		pause_menu = PAUSE_SCENE.instantiate()
		self.get_parent().add_child(pause_menu)
		get_tree().paused = true
	else:
		pause_menu.queue_free()
		get_tree().paused = false

func _input(event):
	if event.is_action_pressed("Esc"):
		get_viewport().set_input_as_handled()
		emit_signal("button_up")
