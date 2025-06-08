extends Node2D

@onready var card_manager: Node2D = $"../CardManager"
@onready var deck: Node2D = $"../Deck"
var discard_pile_hovered: bool = false


func discard_and_buy(discarded_card: Card) -> void:
	discarded_card.position = self.position
	discarded_card.get_node("Area2D/CollisionShape2D").disabled = true
	deck.buy()


func _on_area_2d_mouse_entered() -> void:
	discard_pile_hovered = true


func _on_area_2d_mouse_exited() -> void:
	discard_pile_hovered = false
