extends Node2D

const SUITS: Array[String] = ["copas", "espadas", "ouros", "paus"]
@onready var card_manager: Node2D = $"../CardManager"
@onready var player_hand: Node2D = $"../PlayerHand"

var deck_pile: Array[Card] = []
var deck_pile_hovered: bool = false
var is_empty: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize the deck with all 40 cards
	for suit in SUITS:
		for rank in range(1, 11):
			var new_card: Card = Card.new_card(suit, rank)
			new_card.name = suit + str(rank)
			deck_pile.append(new_card)
			new_card.position = self.position
			card_manager.add_child(new_card)
	deck_pile.shuffle()
	$Label.text = str(deck_pile.size())


func buy() -> void:
	var card = deck_pile.pop_back()
	player_hand.animation_speed = 0.3
	player_hand.add_card_to_hand(card)
	player_hand.animation_speed = 0.2
	card.flip()
	card.get_node("Area2D/CollisionShape2D").disabled = false
	$Label.text = str(deck_pile.size())
	if not deck_pile:
		is_empty = true
		self.get_node("Area2D/CollisionShape2D").disabled = true


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and deck_pile_hovered:
		if event.pressed and not is_empty:
			buy()


func _on_area_2d_mouse_entered() -> void:
	deck_pile_hovered = true


func _on_area_2d_mouse_exited() -> void:
	deck_pile_hovered = false
