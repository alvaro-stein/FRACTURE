extends Node2D
class_name TutorialHowToWin

signal change_scene_to

@onready var card_slot_manager: Node2D = $CardSlotManager
@onready var card_manager: Node2D = $CardManager
@onready var score: Node = $Score
@onready var pointing_arrow: Node2D = $PointingArrow
@onready var pointing_arrow_2: Node2D = $PointingArrow2
@onready var pointing_arrow_3: Node2D = $PointingArrow3
@onready var pointing_arrow_4: Node2D = $PointingArrow4
@onready var pointing_arrow_5: Node2D = $PointingArrow5

func _ready() -> void:
	get_parent().connect_change_scene_signals(self)
	self.position_arrows()
	self.position_cards()
	
func _on_continue_button_button_up() -> void:
	emit_signal("change_scene_to", "TutorialCardTypes")

func _on_return_button_button_up() -> void:
	emit_signal("change_scene_to", "TutorialPlayCard")

func position_cards():
	var new_card_enemy: Card = Card.new_card("GOLD", 7)
	card_manager.add_child(new_card_enemy)
	new_card_enemy.position = Vector2(440.0, 350.0)
	card_slot_manager.get_node("AISlot").get_node(new_card_enemy.color.to_upper()).add_card_to_slot(new_card_enemy, true)
	score_uptade(-new_card_enemy.rank, new_card_enemy.color)
	
	var new_card: Card = Card.new_card("SAPPHIRE", 6)
	card_manager.add_child(new_card)
	new_card.position = Vector2(700, 730.0)
	card_slot_manager.get_node("PlayerSlot").get_node(new_card.color.to_upper()).add_card_to_slot(new_card, false)
	score_uptade(new_card.rank, new_card.color)
	
	new_card_enemy = Card.new_card("GOLD", 9)
	card_manager.add_child(new_card_enemy)
	new_card_enemy.position = Vector2(960.0, 350.0)
	card_slot_manager.get_node("AISlot").get_node("QUARTZ").add_card_to_slot(new_card_enemy, true)
	score_uptade(-new_card_enemy.rank, "QUARTZ")
	
	new_card = Card.new_card("EMERALD", 9)
	card_manager.add_child(new_card)
	new_card.position = Vector2(960.0, 730.0)
	card_slot_manager.get_node("PlayerSlot").get_node("QUARTZ").add_card_to_slot(new_card, false)
	score_uptade(new_card.rank, "QUARTZ")
	
	new_card_enemy= Card.new_card("RUBY", 4)
	card_manager.add_child(new_card_enemy)
	new_card_enemy.position = Vector2(1220, 350.0)
	card_slot_manager.get_node("AISlot").get_node(new_card_enemy.color.to_upper()).add_card_to_slot(new_card_enemy, true)
	score_uptade(-new_card_enemy.rank, new_card_enemy.color)
	
	new_card = Card.new_card("EMERALD", 10)
	card_manager.add_child(new_card)
	new_card.position = Vector2(1480, 730.0)
	card_slot_manager.get_node("PlayerSlot").get_node(new_card.color.to_upper()).add_card_to_slot(new_card, false)
	score_uptade(new_card.rank, new_card.color)
	
func position_arrows():
	pointing_arrow.point_at(Vector2(440.0, 540.0), Vector2(-40, -40))
	pointing_arrow_2.point_at(Vector2(700, 540.0), Vector2(-40, -40))
	pointing_arrow_3.point_at(Vector2(960, 540.0), Vector2(-40, -40))
	pointing_arrow_4.point_at(Vector2(1220, 540.0), Vector2(-40, -40))
	pointing_arrow_5.point_at(Vector2(1480, 540.0), Vector2(-40, -40))
	
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
