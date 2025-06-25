extends Node2D
class_name DeckTypes

signal deck_ready

const COLOR: Array[String] = ["GOLD", "SAPPHIRE", "RUBY", "EMERALD"]
const TYPE: Array[String] = ["ACE", "LOW", "MID", "HIGH"]

var deck_pile: Array[Card] = []
@onready var card_manager: Node2D = $"../CardManager"


func _ready() -> void:
	var i = 0
	for rank in range(11, 1):
		var new_card: Card = Card.new_card(COLOR[i % 4], rank)
		deck_pile.append(new_card)
		new_card.position = self.position
		card_manager.add_child(new_card)
		i += 1
	
	$Label.text = str(deck_pile.size())
	deck_ready.emit.call_deferred()


func buy() -> Card:
	var card = deck_pile.pop_back()
	$Label.text = str(deck_pile.size())
	return card
