class_name CardSlot extends Node2D

#signal hovered
#signal hovered_off

const COLOR: Array[String] = ["GOLD", "SAPPHIRE", "QUARTZ", "RUBY", "EMERALD"]
#const RECT_COLOR: Array[Color] = [Color.DARK_GOLDENROD, Color.DARK_SLATE_BLUE, Color.MISTY_ROSE, Color.FIREBRICK, Color.SEA_GREEN]
const TYPE: Array[String] = ["ACE", "LOW", "MID", "HIGH"]
const OFFSET: int = 103
const CARD_WIDTH: float = 148.0
const COLOR_SPRITE := [preload("res://assets/sprites/Slots/OuroFundo.png"),
					   preload("res://assets/sprites/Slots/SafiraFundo.png"),
					   preload("res://assets/sprites/Slots/QuartzoFundo.png"),
					   preload("res://assets/sprites/Slots/RubiFundo.png"),
					   preload("res://assets/sprites/Slots/EsmeraldaFundo.png")]

@onready var sprite: Sprite2D = $Sprite
var color: String
var slot_pile: Array[Card] = []
var total: int


func add_card_to_slot(card: Card, is_AI: bool) -> void:
	card.get_node("Area2D/CollisionShape2D").disabled = true
	card.scale = Vector2(1, 1)
	if card.is_facing_down:
		card.flip(true)
	# Insert sorted from low to high
	slot_pile.append(card)
	slot_pile.sort_custom(func(a: Card, b: Card): return a.rank < b.rank)
	self.update_slot(is_AI)


func update_slot(is_AI: bool):
	if slot_pile[0].type == "ACE":
		slot_pile[0].card_set_z_index(0)
		var new_pos := Vector2(self.position.x, self.position.y + OFFSET)
		if is_AI:
			new_pos.y = new_pos.y - 2*OFFSET
		var tween = slot_pile[0].create_tween()
		tween.tween_property(slot_pile[0], "position", new_pos, 0.2)
		total = slot_pile.size() - 1
		for index in range(1, slot_pile.size()):
			calculate_new_position(index, is_AI)
			order_z_index(index)
	else:
		total = slot_pile.size()
		for index in slot_pile.size():
			calculate_new_position(index, is_AI)
			order_z_index(index)


func order_z_index(index) -> void:
	slot_pile[index].card_set_z_index(-index)


func calculate_new_position(index: int, is_AI: bool) -> void:
	var i = slot_pile.size() - index
	var total_width = total*CARD_WIDTH/4 + 3*CARD_WIDTH/4
	var new_x_pos = self.position.x + (i+1) * CARD_WIDTH/4 - total_width/2
	var new_pos := Vector2(new_x_pos, self.position.y - OFFSET)
	if is_AI:
		new_pos.y = new_pos.y + 2*OFFSET
	# Anima carta para a posição nova
	var tween = slot_pile[index].create_tween()
	tween.tween_property(slot_pile[index], "position", new_pos, 0.2)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color = self.name
	sprite.texture = COLOR_SPRITE[COLOR.find(color)]
