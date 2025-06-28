extends Control
class_name CreditosMenu


func _input(event):
	if event.is_action_pressed("Esc"):
		_on_voltar_button_pressed()


func _on_voltar_button_pressed() -> void:
	AudioGlobal.button.play()
	self.get_parent().close_option()
