extends Node2D

signal change_scene_to


@onready var card_slot_manager: Node2D = $CardSlotManager
@onready var card_manager: Node2D = $CardManager
@onready var score: Node = $Score

func _on_continue_button_button_up() -> void:
	emit_signal("change_scene_to", "Tutorial5")

func _on_return_button_button_up() -> void:
	emit_signal("change_scene_to", "Tutorial7")

func _ready() -> void:
	#get_parent().connect_change_scene_signals(self)
	self.hide_slots()
	self.position_cards()


func position_cards():
	var new_card: Card = Card.new_card("GOLD", 10)
	card_manager.add_child(new_card)
	new_card.position = Vector2(440.0, 730.0)
	card_slot_manager.get_node("PlayerSlot").get_node(new_card.color.to_upper()).add_card_to_slot(new_card, false)
	score_uptade(new_card.rank, new_card.color)
	
	new_card = Card.new_card("GOLD", 4)
	card_manager.add_child(new_card)
	new_card.position = Vector2(440.0, 730.0)
	card_slot_manager.get_node("PlayerSlot").get_node(new_card.color.to_upper()).add_card_to_slot(new_card, false)
	score_uptade(new_card.rank, new_card.color)
	
	new_card = Card.new_card("SAPPHIRE", 9)
	card_manager.add_child(new_card)
	new_card.position = Vector2(700.0, 730.0)
	card_slot_manager.get_node("PlayerSlot").get_node(new_card.color).add_card_to_slot(new_card, false)
	score_uptade(new_card.rank, new_card.color)
	
	new_card = Card.new_card("EMERALD", 9)
	card_manager.add_child(new_card)
	new_card.position = Vector2(960.0, 730.0)
	card_slot_manager.get_node("PlayerSlot").get_node("QUARTZ").add_card_to_slot(new_card, false)
	score_uptade(new_card.rank, "QUARTZ")
	
	new_card = Card.new_card("RUBY", 10)
	card_manager.add_child(new_card)
	new_card.position = Vector2(1220, 730.0)
	card_slot_manager.get_node("PlayerSlot").get_node(new_card.color.to_upper()).add_card_to_slot(new_card, false)
	score_uptade(new_card.rank, new_card.color)
	
	new_card = Card.new_card("EMERALD", 10)
	card_manager.add_child(new_card)
	new_card.position = Vector2(1480, 730.0)
	card_slot_manager.get_node("PlayerSlot").get_node(new_card.color.to_upper()).add_card_to_slot(new_card, false)
	score_uptade(new_card.rank, new_card.color)
	
func score_uptade(value, color):
	score.get_node(color.to_upper()).get_node("SpinScore").play("spin score")
	var score_label: Label = score.get_node(color.to_upper())
	score_label.text = str(int(score_label.text) + value)
	if int(score_label.text) == 0:
		score_label.set("theme_override_colors/font_color", Color.BLACK)
	elif int(score_label.text) < 0:
		score_label.set("theme_override_colors/font_color", Color.FIREBRICK)
	else:
		score_label.set("theme_override_colors/font_color", Color.SEA_GREEN)

func hide_slots():
	for slot in card_slot_manager.get_node("AISlot").get_children():
		slot.visible = false
