extends Control
class_name MainMenu

signal change_scene_to


func _ready() -> void:
	get_parent().connect_change_scene_signals(self)
	
	for _button in get_tree().get_nodes_in_group("buttons"):
		_button.pressed.connect(_on_button_pressed.bind(_button))


func _on_button_pressed(_button : Button) -> void:
	var audio = get_node("somfundo")
	# Garantir que o áudio esteja na árvore de nós principal
	if audio.get_parent() != get_tree().root:
		audio.reparent(get_tree().root)  # Move para a raiz da árvore
		audio.owner = null  # Garante que o nó não seja deletado
  
	var sound_player = [$botaosom, $botaosom2, $botaosom3].pick_random()  	# Escolhe aleatoriamente um dos sons
	sound_player.play()
	await sound_player.finished
	
	match _button.name:
		"jogar_button":
			emit_signal("change_scene_to", "Match")
			#get_tree().change_scene_to_file("res://Interface/Menu_Personagens/CharacterSelect/character_select_scene.tscn")
		"tutorial_button":
			emit_signal("change_scene_to", "Tutorial")
		"regras_button":
			emit_signal("change_scene_to", "Regras")
		"configuracao_button":
			emit_signal("change_scene_to", "Config")
		"creditos_button":
			emit_signal("change_scene_to", "Creditos")
		"sair_button":
			get_tree().quit()
