extends Control

signal change_scene_to

func _ready() -> void:
	get_parent().get_parent().connect_change_scene_signals(self)


func _on_singleplayer_pressed() -> void:
	AudioGlobal.button.play()
	self.get_parent().close_option()
	self.get_parent().open_option("SingleplayerSelection")


var tween: Tween # Usando só pra label do aviso temporário do multiplayer
func _on_multiplayer_pressed() -> void:
	AudioGlobal.button.play()
	if tween:
		tween.stop()
	tween = self.create_tween()
	$ButtonsBox/Multiplayer/Label.modulate.a = 1
	tween.tween_property($ButtonsBox/Multiplayer/Label, "modulate:a", 0, 2)


func _on_tutorial_pressed() -> void:
	AudioGlobal.button.play()
	emit_signal("change_scene_to", "TutorialDeck")


func _on_regras_pressed() -> void:
	AudioGlobal.button.play()
	self.get_parent().close_option()
	self.get_parent().open_option("Regras")


func _on_voltar_pressed() -> void:
	AudioGlobal.button.play()
	self.get_parent().close_option()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Esc"):
		_on_voltar_pressed()
