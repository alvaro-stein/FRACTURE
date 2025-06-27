extends Control
class_name MainMenu

signal change_scene_to

const REGRAS_SCENE := preload("res://scenes/Menu/Regras/regras.tscn")
const CONFIG_SCENE := preload("res://scenes/Menu/Configuracoes/menu_configuracao.tscn")
const CREDITOS_SCENE := preload("res://scenes/Menu/Creditos/creditos.tscn")

var current_option: Node = null


func open_option(option: String) -> void:
	$ButtonsBox.visible = false
	$titulo.visible = false
	match option:
		"Regras":
			current_option = REGRAS_SCENE.instantiate()
			self.add_child(current_option)
		"Config":
			current_option = CONFIG_SCENE.instantiate()
			self.add_child(current_option)
		"Creditos":
			current_option = CREDITOS_SCENE.instantiate()
			self.add_child(current_option)

func close_option() -> void:
	current_option.queue_free()
	$ButtonsBox.visible = true
	$titulo.visible = true

func _ready() -> void:
	get_parent().connect_change_scene_signals(self)
	
	for _button in get_tree().get_nodes_in_group("buttons"):
		_button.pressed.connect(_on_button_pressed.bind(_button))


func _on_button_pressed(_button : Button) -> void:
	#var audio = get_node("somfundo")
	## Garantir que o áudio esteja na árvore de nós principal
	#if audio.get_parent() != get_tree().root:
		#audio.reparent(get_tree().root)  # Move para a raiz da árvore
		#audio.owner = null  # Garante que o nó não seja deletado
  
	#var sound_player = [$botaosom, $botaosom2, $botaosom3].pick_random()  	# Escolhe aleatoriamente um dos sons
	#sound_player.play()
	#await sound_player.finished
	
	match _button.name:
		"jogar_button":
			emit_signal("change_scene_to", "Match")
		"tutorial_button":
			emit_signal("change_scene_to", "TutorialDeck")
		"regras_button":
			open_option("Regras")
		"configuracao_button":
			open_option("Config")
		"creditos_button":
			open_option("Creditos")
		"sair_button":
			get_tree().quit()
