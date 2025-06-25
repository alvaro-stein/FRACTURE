extends Control
class_name MainMenu

signal change_scene_to

const REGRAS_SCENE := preload("res://scenes/Menu/Regras/regras.tscn")
const CONFIG_SCENE := preload("res://scenes/Menu/Configuracoes/menu_configuracao.tscn")
const CREDITOS_SCENE := preload("res://scenes/Menu/Creditos/creditos.tscn")


@onready var buttons_box: MarginContainer = $ButtonsBox
var current_option: Node = null


func open_option(option: String) -> void:
	buttons_box.visible = true
	match option:
		"Regras":
			pass
		"Config":
			pass
		"Creditos":
			pass

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
		"tutorial_button":
			emit_signal("change_scene_to", "Tutorial")
		"regras_button":
			#emit_signal("change_scene_to", "Regras")
			open_option("Regras")
		"configuracao_button":
			#emit_signal("change_scene_to", "Config")
			open_option("Config")
		"creditos_button":
			emit_signal("change_scene_to", "Creditos")
			open_option("Creditos")
		"sair_button":
			get_tree().quit()
