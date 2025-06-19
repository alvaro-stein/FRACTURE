extends Node2D
class_name DiscardPile

var discard_pile_hovered: bool = false
var discard_pile: Array[Card] = []

func discard_card(card: Card):
	card.position = self.position
	self.discard_pile.append(card)
	card.get_node("Area2D/CollisionShape2D").disabled = true
	card.flip()

func _on_area_2d_mouse_entered() -> void:
	discard_pile_hovered = true


func _on_area_2d_mouse_exited() -> void:
	discard_pile_hovered = false
