extends Node2D

signal change_scene_to

@onready var card_slot_manager: Node2D = $CardSlotManager
@onready var card_manager: Node2D = $CardManager
@onready var clock: Button = $Clock
@onready var text_box: RicherTextLabel = $TextBox

func _on_continue_button_button_up() -> void:
	emit_signal("change_scene_to", "TutorialDeck")

func _on_return_button_button_up() -> void:
	emit_signal("change_scene_to", "TutorialCostMana")

func _ready() -> void:
	#get_parent().connect_change_scene_signals(self)
	clock._end_turn.connect(clock_clicked)
	clock.reset_timer()
	
func clock_clicked():
	text_box.text = "Clicou no clock"
	pass
