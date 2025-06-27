extends Node2D
class_name DeckEndGame

signal deck_ready

const COLOR: Array[String] = ["GOLD", "SAPPHIRE", "RUBY", "EMERALD"]
const TYPE: Array[String] = ["ACE", "LOW", "MID", "HIGH"]

var deck_pile: Array[Card] = []
@onready var card_manager: Node2D = $"../CardManager"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize the deck with all 40 cards
	var new_card: Card = Card.new_card("RUBY", 9)
	#new_card.name = suit + str(rank)
	deck_pile.append(new_card)
	new_card.position = self.position
	card_manager.add_child(new_card)
	$Label.text = str(deck_pile.size())
	deck_ready.emit.call_deferred()

func buy() -> Card:
	var card = deck_pile.pop_back()
	$Label.text = str(deck_pile.size())
	return card
