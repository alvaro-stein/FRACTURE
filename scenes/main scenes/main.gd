extends Node2D

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
					  "TutorialCostMana": "res://scenes/main scenes/Tutorial/TutorialCostMana/tuturial_cost_mana.tscn",
					  "TutorialForge2": "res://scenes/main scenes/Tutorial/TutorialForge2/tutorial_forge2.tscn",
					  "TutorialEndTurn": "res://scenes/main scenes/Tutorial/TutorialEndTurn/tutorial_end_turn.tscn",
					  "TutorialEndGame": "res://scenes/main scenes/Tutorial/TutorialEndGame/tutorial_end_game.tscn",
					  "TutorialFinal": "res://scenes/main scenes/Tutorial/TutorialFinal/tutorial_final.tscn",
					}

var current_scene: Node = null

func _ready() -> void:
	var initial_scene = load(SCENES_PATHS["TutorialDeck"]).instantiate()
	self.add_child(initial_scene)
	current_scene = initial_scene

func _on_change_scene_to(next_scene: String):
	var new_scene: Node = load(SCENES_PATHS[next_scene]).instantiate()
	current_scene.queue_free()
	self.add_child(new_scene)
	current_scene = new_scene

func connect_change_scene_signals(scene: Node):
	scene.connect("change_scene_to", _on_change_scene_to)
