extends Node2D


func _input(event):
	if event.is_action_pressed("Esc"):
		_on_voltar_pressed()

func _on_voltar_pressed() -> void:
	AudioGlobal.button.play()
	self.get_parent().close_option()
	self.get_parent().open_option("CharacterSelection")
