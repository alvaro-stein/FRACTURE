extends Node2D

var standard_z_index = self.z_index
var card_being_dragged: Card = null
var highlighted_card: Card = null
var last_card_hovered: Card = null


func connect_card_signals(card: Card) -> void:
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)


func on_hovered_over_card(card: Card) -> void:
	last_card_hovered = card
	if not highlighted_card:
		highlighted_card = card
		highlight_card(card, true)


func on_hovered_off_card(card: Card) -> void:
	if highlighted_card == card:
		highlighted_card = null
		highlight_card(card, false)
		if last_card_hovered != card:
			highlighted_card = last_card_hovered
			highlight_card(last_card_hovered, true)
		else:
			last_card_hovered = null
	else:
		last_card_hovered = highlighted_card


func highlight_card(card: Card, hovered: bool) -> void:
	if hovered:
		card.scale = Vector2(1.05, 1.05)
		card.card_set_z_index(card.z_index+1)
	else:
		card.scale = Vector2(1, 1)
		if not card.get_node("Area2D/CollisionShape2D").disabled:
			card.card_set_z_index(card.z_index-1)
