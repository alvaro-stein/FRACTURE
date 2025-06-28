extends Control

signal change_scene_to

func _ready() -> void:
	get_parent().get_parent().connect_change_scene_signals(self)
	#
	#for _button in get_tree().get_nodes_in_group("buttons"):
		#_button.pressed.connect(_on_button_pressed.bind(_button))
#
#
#func _on_button_pressed(_button : Button) -> void:
	#match _button.name:
		#"Singleplayer":
			##emit_signal("change_scene_to", "Match")
			##open_option("Jogar")
			#pass
		#"Multiplayer":
			#pass
		#"Tutorial":
			#emit_signal("change_scene_to", "TutorialDeck")
		#"Regras":
			##open_option("Regras")
			#pass
		#"Voltar":
			#self.get_parent().close_option()
			


func _on_singleplayer_pressed() -> void:
	AudioGlobal.button.play()
	self.get_parent().close_option()
	self.get_parent().open_option("SingleplayerSelection")


func _on_multiplayer_pressed() -> void:
	AudioGlobal.button.play()
	pass # Replace with function body.


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
