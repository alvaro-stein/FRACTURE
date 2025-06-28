extends Node2D
class_name TutorialMana

signal change_scene_to

@onready var mana_p_1: Sprite2D = $Mana/ManaP1
@onready var mana_p_2: Sprite2D = $Mana/ManaP2
@onready var mana_g: Sprite2D = $Mana/ManaG

const MANA_GRANDE = preload("res://assets/mana/Mana Grande.png")
const MANA_PEQUENA = preload("res://assets/mana/Mana Pequena.png")

func _on_continue_button_button_up() -> void:
	AudioGlobal.button.play()
	emit_signal("change_scene_to", "TutorialCostMana")

func _on_return_button_button_up() -> void:
	AudioGlobal.button.play()
	emit_signal("change_scene_to", "TutorialDiscard") 
	
func _ready() -> void:
	get_parent().connect_change_scene_signals(self)
	pass
	
