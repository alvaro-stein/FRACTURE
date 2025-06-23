extends Control
class_name RegrasMenu

signal change_scene_to

@export var cena_inicial: String


func _input(event):
	if event.is_action_pressed("Esc"): 
		emit_signal("change_scene_to", "Menu")


func _ready() -> void:
	get_parent().connect_change_scene_signals(self)


func _on_sair_button_pressed() -> void:
	var sound_player = [$botaosom, $botaosom2, $botaosom3].pick_random()  # Escolhe aleatoriamente um dos sons
	sound_player.play()
	await sound_player.finished

	emit_signal("change_scene_to", "Menu")
