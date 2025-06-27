extends Node2D
class_name TutorialFinal

signal change_scene_to

func _ready() -> void:
	get_parent().connect_change_scene_signals(self)

func _on_menu_button_button_up() -> void:
	emit_signal("change_scene_to", "Menu")

func _on_play_button_button_up() -> void:
	emit_signal("change_scene_to", "Match")
