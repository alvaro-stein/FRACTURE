extends Node2D
class_name DiscardPile

var discard_pile: Array[Card] = []

func discard_card(card: Card):
	if not card:
		print("CARTA NULL, NÃO DEVERIA ESTAR TENTANDO DESCARTAR")
	if not card.is_facing_down:
		card.flip(false)
	card.position = self.position
	self.discard_pile.append(card)
	card.get_node("Area2D/CollisionShape2D").disabled = true
	card.card_set_z_index(-5) # any number
