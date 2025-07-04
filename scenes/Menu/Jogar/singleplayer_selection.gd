extends Control

signal change_scene_to

func _ready() -> void:
	get_parent().get_parent().connect_change_scene_signals(self)


func _input(event):
	if event.is_action_pressed("Esc"):
		_on_voltar_pressed()


func _on_singleplayer_pressed() -> void:
	_on_voltar_pressed()


func _on_facil_pressed() -> void:
	AudioGlobal.button.play()
	GameSettings.ai_difficulty = "easy"
	self.get_parent().close_option()
	self.get_parent().open_option("CharacterSelection")


func _on_medio_pressed() -> void:
	AudioGlobal.button.play()
	GameSettings.ai_difficulty = "medium"
	self.get_parent().close_option()
	self.get_parent().open_option("CharacterSelection")


func _on_dificil_pressed() -> void:
	AudioGlobal.button.play()
	GameSettings.ai_difficulty = "hard"
	self.get_parent().close_option()
	self.get_parent().open_option("CharacterSelection")


func _on_voltar_pressed() -> void:
	AudioGlobal.button.play()
	self.get_parent().close_option()
	self.get_parent().open_option("Jogar")
