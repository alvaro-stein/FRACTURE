extends Node2D
class_name TutorialCostMana

signal change_scene_to

func _on_continue_button_button_up() -> void:
	emit_signal("change_scene_to", "Tutorial10")


func _on_return_button_button_up() -> void:
	emit_signal("change_scene_to", "Tutorial8")
