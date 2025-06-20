class_name CardSlot extends Node2D

signal hovered
signal hovered_off

const COLOR: Array[String] = ["GOLD", "SAPPHIRE", "QUARTZ", "RUBY", "EMERALD"]
const TYPE: Array[String] = ["ACE", "LOW", "MID", "HIGH"]
const OFFSET: int = 103
const CARD_WIDTH: float = 148.0

var color: String
var slot_pile: Array[Card] = []
var total: int


func add_card_to_slot(card: Card) -> void:
	card.get_node("Area2D/CollisionShape2D").disabled = true
	if card.is_facing_down:
		card.flip()
	# Insert sorted from low to high
	slot_pile.append(card)
	slot_pile.sort_custom(func(a: Card, b: Card): return a.rank < b.rank)
	self.update_slot()


func update_slot():
	if slot_pile[0].type == "ACE":
		slot_pile[0].card_set_z_index(0)
		var new_pos := Vector2(self.position.x, self.position.y + OFFSET)
		var tween = slot_pile[0].create_tween()
		tween.tween_property(slot_pile[0], "position", new_pos, 0.2)
		total = slot_pile.size() - 1
		for index in range(1, slot_pile.size()):
			calculate_new_position(index)
			order_z_index(index)
	else:
		total = slot_pile.size()
		for index in slot_pile.size():
			calculate_new_position(index)
			order_z_index(index)


func order_z_index(index) -> void:
	slot_pile[index].card_set_z_index(-index)


func calculate_new_position(index: int) -> void:
	var i = slot_pile.size() - index
	var total_width = total*CARD_WIDTH/4 + 3*CARD_WIDTH/4
	var new_x_pos = self.position.x + (i+1) * CARD_WIDTH/4 - total_width/2
	var new_pos := Vector2(new_x_pos, self.position.y - OFFSET)
	# Anima carta para a posição nova
	var tween = slot_pile[index].create_tween()
	tween.tween_property(slot_pile[index], "position", new_pos, 0.2)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color = self.name.to_upper()
	# All Cards slots must be a child of CardSlotManager or this will error
	get_parent().get_parent().connect_card_slot_signals(self)


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
