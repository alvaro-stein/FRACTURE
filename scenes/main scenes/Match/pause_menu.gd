extends ColorRect

@onready var label: RichTextLabel = $RichTextLabel
@onready var sair: Button = $Sair
@onready var reiniciar: Button = $Reiniciar
@onready var configuracao: Control = $MenuConfiguracao

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if self.get_parent() is GameManager: # Se for a Match
		sair.text = "Sair da partida"
	else: # Caso contrário, é qualquer um dos tutoriais
		reiniciar.queue_free()
		sair.position.y -= 60
		sair.text = "Sair do tutorial"
	
	configuracao.get_node("ColorRect").queue_free()
	configuracao.get_node("VoltarButton").queue_free()
	label.modulate.a = 0
	sair.modulate.a = 0
	reiniciar.modulate.a = 0
	configuracao.modulate.a = 0
	var tween1 = self.create_tween()
	var tween2 = self.create_tween()
	var tween3 = self.create_tween()
	var tween4 = self.create_tween()
	tween1.tween_property(label, "modulate:a", 1.0, 0.5)
	tween2.tween_property(sair, "modulate:a", 1.0, 0.5)
	tween3.tween_property(reiniciar, "modulate:a", 1.0, 0.5)
	tween4.tween_property(configuracao, "modulate:a", 1.0, 0.5)


func _on_sair_pressed() -> void:
	AudioGlobal.button.play()
	get_tree().paused = false
	self.get_parent().emit_signal("change_scene_to", "Menu")


func _on_reiniciar_pressed() -> void:
	AudioGlobal.button.play()
	get_tree().paused = false
	self.get_parent().emit_signal("change_scene_to", "Match")
