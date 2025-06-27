extends ColorRect

@onready var label: RicherTextLabel = $RicherTextLabel
@onready var button: Button = $Button
@onready var configuracao: Control = $MenuConfiguracao

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match self.get_parent().name:
		"Match":
			button.text = "Sair da partida"
		_: # Qualquer um dos tutoriais
			button.text = "Sair do tutorial"
	
	
	configuracao.get_node("ColorRect").queue_free()
	configuracao.get_node("VoltarButton").queue_free()
	label.modulate.a = 0
	button.modulate.a = 0
	configuracao.modulate.a = 0
	var tween1 = self.create_tween()
	var tween2 = self.create_tween()
	var tween3 = self.create_tween()
	tween1.tween_property(label, "modulate:a", 1.0, 0.5)
	tween2.tween_property(button, "modulate:a", 1.0, 0.5)
	tween3.tween_property(configuracao, "modulate:a", 1.0, 0.5)


func _on_button_button_up() -> void:
	get_tree().paused = false
	self.get_parent().emit_signal("change_scene_to", "Menu")
