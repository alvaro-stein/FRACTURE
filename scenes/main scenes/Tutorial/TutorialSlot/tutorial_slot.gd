extends Node2D

signal change_scene_to


func _ready() -> void:
	get_parent().connect_change_scene_signals(self)
	pass
	
func _on_return_button_button_up() -> void:
	AudioGlobal.button.play()
	emit_signal("change_scene_to", "TutorialDeck")

func _on_continue_button_button_up() -> void:
	AudioGlobal.button.play()
	emit_signal("change_scene_to", "TutorialPlayCard")

		
	
	
