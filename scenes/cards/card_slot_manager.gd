extends Node2D

var card_slot_hovered: CardSlot = null

# Card slot implementation
func connect_card_slot_signals(card_slot: CardSlot) -> void:
	card_slot.connect("hovered", on_hovered_over_card_slot)
	card_slot.connect("hovered_off", on_hovered_off_card_slot)


# Does not handle overlapping card slots (probably not needed)
func on_hovered_over_card_slot(card_slot: CardSlot) -> void:
	card_slot_hovered = card_slot


func on_hovered_off_card_slot(card_slot: CardSlot) -> void:
	card_slot_hovered = null


## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
