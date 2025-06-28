extends Control

signal change_scene_to

func _ready() -> void:
	get_parent().get_parent().connect_change_scene_signals(self)


func _input(event):
	if event.is_action_pressed("Esc"):
		self.get_parent().close_option()
		self.get_parent().open_option("Jogar")


func _on_singleplayer_pressed() -> void:
	self.get_parent().close_option()
	self.get_parent().open_option("Jogar")


func _on_facil_pressed() -> void:
	GameSettings.ai_difficulty = "easy"
	
	#self.get_parent().close_option()
	#self.get_parent().open_option("CharacterSelection")
	
	emit_signal("change_scene_to", "Match")


func _on_medio_pressed() -> void:
	GameSettings.ai_difficulty = "medium"
	
	#self.get_parent().close_option()
	#self.get_parent().open_option("CharacterSelection")
	
	emit_signal("change_scene_to", "Match")


func _on_dificil_pressed() -> void:
	GameSettings.ai_difficulty = "hard"
	
	#self.get_parent().close_option()
	#self.get_parent().open_option("CharacterSelection")
	
	emit_signal("change_scene_to", "Match")


func _on_voltar_pressed() -> void:
	self.get_parent().close_option()
	self.get_parent().open_option("Jogar")
