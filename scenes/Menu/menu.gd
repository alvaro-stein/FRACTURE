extends Control
class_name MainMenu

signal change_scene_to

const REGRAS_SCENE := preload("res://scenes/Menu/Regras/regras.tscn")
const CONFIG_SCENE := preload("res://scenes/Menu/Configuracoes/menu_configuracao.tscn")
const CREDITOS_SCENE := preload("res://scenes/Menu/Creditos/creditos.tscn")
const JOGAR_SCENE := preload("res://scenes/Menu/Jogar/jogar.tscn")
const SINGLEPLAYER_SELECTION_SCENE := preload("res://scenes/Menu/Jogar/singleplayer_selection.tscn")
const CHARACTER_SELECTION_SCENE := preload("res://scenes/Menu/Jogar/CharacterSelect/character_selection.tscn")
const LORE_SCENE := preload("res://scenes/Secundary Scenes/lore.tscn")

var current_option: Node = null


func open_option(option: String) -> void:
	$ButtonsBox.visible = false
	$titulo.visible = false
	match option:
		"Jogar":
			$titulo.visible = true
			current_option = JOGAR_SCENE.instantiate()
			self.add_child(current_option)
		"SingleplayerSelection":
			$titulo.visible = true
			current_option = SINGLEPLAYER_SELECTION_SCENE.instantiate()
			self.add_child(current_option)
		"CharacterSelection":
			current_option = CHARACTER_SELECTION_SCENE.instantiate()
			self.add_child(current_option)
		"Lore":
			current_option = LORE_SCENE.instantiate()
			self.add_child(current_option)
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
	var italic_font: Font = $titulo.get_theme_font("italics_font")
	italic_font.variation_embolden = 0
	get_parent().connect_change_scene_signals(self)
	
	for _button in get_tree().get_nodes_in_group("buttons"):
		_button.pressed.connect(_on_button_pressed.bind(_button))


func _on_button_pressed(_button : Button) -> void:
	AudioGlobal.button.play()
	match _button.name:
		"jogar_button":
			open_option("Jogar")
		"configuracao_button":
			open_option("Config")
		"creditos_button":
			open_option("Creditos")
		"sair_button":
			get_tree().quit()
