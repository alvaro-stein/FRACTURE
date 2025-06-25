extends Node2D

const TRANSITION_SCENE = preload("res://scenes/main scenes/scene_transition.tscn")
const SCENES_PATHS = {"Menu": "res://scenes/Menu/menu.tscn",
					  "Match": "res://scenes/main scenes/Match/match.tscn",
					  "Regras": "res://scenes/Menu/Regras/regras.tscn",
					  "Config": "res://scenes/Menu/Configuracoes/menu_configuracao.tscn",
					  "Creditos": "res://scenes/Menu/Creditos/creditos.tscn"}

var current_scene: Node = null

func _ready() -> void:
	var initial_scene = load(SCENES_PATHS["Menu"]).instantiate()
	self.add_child(initial_scene)
	current_scene = initial_scene

func _on_change_scene_to(next_scene: String):
	var transition = TRANSITION_SCENE.instantiate()
	var animation = transition.get_node("AnimationPlayer")
	self.add_child(transition)
	animation.play("transition")
	await animation.animation_finished

	current_scene.queue_free()
	var new_scene: Node = load(SCENES_PATHS[next_scene]).instantiate()
	self.add_child(new_scene)
	animation.play_backwards("transition")
	await animation.animation_finished

	current_scene = new_scene
	transition.queue_free()

func connect_change_scene_signals(scene: Node):
	scene.connect("change_scene_to", _on_change_scene_to)
