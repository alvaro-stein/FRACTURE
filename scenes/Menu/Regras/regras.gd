extends Control
class_name RegrasMenu


func _input(event):
	if event.is_action_pressed("Esc"):
		self.get_parent().close_option()
		self.get_parent().open_option("Jogar")


func _on_voltar_button_pressed() -> void:
	#var sound_player = [$botaosom, $botaosom2, $botaosom3].pick_random()  # Escolhe aleatoriamente um dos sons
	#sound_player.play()
	#await sound_player.finished

	self.get_parent().close_option()
	self.get_parent().open_option("Jogar")
