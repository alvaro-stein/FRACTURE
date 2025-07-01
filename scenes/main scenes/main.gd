extends Node2D

const TRANSITION_SCENE = preload("res://scenes/main scenes/scene_transition.tscn")
const SCENES_PATHS = {"Menu": "res://scenes/Menu/menu.tscn",
					  "Match": "res://scenes/main scenes/Match/match.tscn",
					  "Regras": "res://scenes/Menu/Regras/regras.tscn",
					  "Config": "res://scenes/Menu/Configuracoes/menu_configuracao.tscn",
					  "Creditos": "res://scenes/Menu/Creditos/creditos.tscn",
					  "TutorialDeck": "res://scenes/main scenes/Tutorial/TutorialDeck/tutorial_deck.tscn",
					  "TutorialSlot": "res://scenes/main scenes/Tutorial/TutorialSlot/tutorial_slot.tscn",
					  "TutorialPlayCard": "res://scenes/main scenes/Tutorial/TutorialPlayCard/tutorial_play_card.tscn",
					  "TutorialHowToWin": "res://scenes/main scenes/Tutorial/TutorialHowToWin/tutorial_how_to_win.tscn",
					  "TutorialCardTypes": "res://scenes/main scenes/Tutorial/TutorialCardTypes/tutorial_card_types.tscn",
					  "TutorialCombinations": "res://scenes/main scenes/Tutorial/TutorialCombinations/tutorial_combinations.tscn",
					  "TutorialDiscard": "res://scenes/main scenes/Tutorial/TutorialDiscard/tutorial_discard.tscn",
					  "TutorialMana": "res://scenes/main scenes/Tutorial/TutorialMana/tutorial_mana.tscn",
					  "TutorialCostMana": "res://scenes/main scenes/Tutorial/TutorialCostMana/tutorial_cost_mana.tscn",
					  "TutorialForge2": "res://scenes/main scenes/Tutorial/TutorialForge2/tutorial_forge2.tscn",
					  "TutorialEndTurn": "res://scenes/main scenes/Tutorial/TutorialEndTurn/tutorial_end_turn.tscn",
					  "TutorialEndGame": "res://scenes/main scenes/Tutorial/TutorialEndGame/tutorial_end_game.tscn",
					  "TutorialFinal": "res://scenes/main scenes/Tutorial/TutorialFinal/tutorial_final.tscn",
					 }


@onready var black_background: ColorRect = $BlackBackground

var current_scene: Node = null


func _ready() -> void:
	var initial_scene = load(SCENES_PATHS["Menu"]).instantiate()
	self.add_child(initial_scene)
	current_scene = initial_scene
	AudioGlobal.opening.play()
	AudioGlobal.music.play()
	var tween = get_tree().create_tween()
	tween.tween_property(black_background, "modulate:a", 0, 3)
	await tween.finished
	black_background.queue_free()

func _on_change_scene_to(next_scene: String):
	var transition = TRANSITION_SCENE.instantiate()
	var animation = transition.get_node("AnimationPlayer")
	self.add_child(transition)
	animation.play("transition")
	await animation.animation_finished
	
	current_scene.queue_free()
	var new_scene: Node = load(SCENES_PATHS[next_scene]).instantiate()
	current_scene = new_scene
	self.add_child(new_scene)
	animation.play_backwards("transition")
	await animation.animation_finished
	transition.queue_free()

func connect_change_scene_signals(scene: Node):
	scene.connect("change_scene_to", _on_change_scene_to)
