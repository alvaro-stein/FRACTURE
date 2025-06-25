extends Node2D

const SCENES_PATHS = {"Menu": "res://scenes/Menu/menu.tscn",
					  "Match": "res://scenes/main scenes/Match/match.tscn",
					  "Regras": "res://scenes/Menu/Regras/regras.tscn",
					  "Config": "res://scenes/Menu/Configuracoes/menu_configuracao.tscn",
					  "Creditos": "res://scenes/Menu/Creditos/creditos.tscn",
					  "Tutorial1": "res://scenes/main scenes/Tutorial/Tutorial1/tutorial_deck.tscn",
					  "Tutorial2": "res://scenes/main scenes/Tutorial/Tutorial2/tutorial_slot.tscn",
					}

var current_scene: Node = null

func _ready() -> void:
	var initial_scene = load(SCENES_PATHS["Menu"]).instantiate()
	self.add_child(initial_scene)
	current_scene = initial_scene

func _on_change_scene_to(next_scene: String):
	var new_scene: Node = load(SCENES_PATHS[next_scene]).instantiate()
	current_scene.queue_free()
	self.add_child(new_scene)
	current_scene = new_scene

func connect_change_scene_signals(scene: Node):
	scene.connect("change_scene_to", _on_change_scene_to)
