extends Node2D
class_name TutorialMana

signal change_scene_to

func _on_continue_button_button_up() -> void:
	emit_signal("change_scene_to", "Tutorial9")

func _on_return_button_button_up() -> void:
	emit_signal("change_scene_to", "Tutorial7") 
	
func _ready() -> void:
	#get_parent().connect_change_scene_signals(self)
	pass
	
