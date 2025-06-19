extends Node2D
class_name Deck

const SUITS: Array[String] = ["copas", "espadas", "ouros", "paus"]
@onready var card_manager: Node2D = $"../CardManager"

var deck_pile: Array[Card] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize the deck with all 40 cards
	for suit in SUITS: 
		for rank in range(1, 11):
			var new_card: Card = Card.new_card(suit, rank)
			#new_card.name = suit + str(rank)
			deck_pile.append(new_card)
			new_card.position = self.position
			card_manager.add_child(new_card)
	deck_pile.shuffle()
	$Label.text = str(deck_pile.size())


func buy() -> Card:
	var card = deck_pile.pop_back()
	$Label.text = str(deck_pile.size())
	return card
