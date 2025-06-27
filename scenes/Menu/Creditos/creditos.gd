extends Control
class_name CreditosMenu


func _input(event):
	if event.is_action_pressed("Esc"): 
		self.get_parent().close_option()


func _on_voltar_button_pressed() -> void:
	self.get_parent().close_option()
