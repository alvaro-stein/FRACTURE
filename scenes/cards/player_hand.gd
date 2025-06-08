extends Node2D

const TRUE_CARD_WIDTH: float = 148.0
const CARD_WIDTH: float = TRUE_CARD_WIDTH * 1.10
const TRUE_CARD_HEIGHT: float = 200.0
const CARD_HEIGHT: float = TRUE_CARD_HEIGHT * 1.10
const HAND_Y_POS: float = 1080 + TRUE_CARD_HEIGHT/6 # 1 terço a mostra
var player_hand: Array[Card] = []
var screen_center_x: float
var total_width: float
var x_offset: float



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_center_x = get_viewport_rect().size.x / 2


func remove_card_from_hand(card: Card) -> void:
	if card in player_hand:
		var index = player_hand.find(card)
		player_hand.remove_at(index)
		update_hand()

func add_card_to_hand(card: Card) -> void:
	if card not in player_hand:
		player_hand.append(card)
		update_hand()

func update_hand() -> void:
	for index in player_hand.size():
		update_card_position(index)

func update_card_position(index: int) -> void:
	total_width = (player_hand.size() -1) * CARD_WIDTH
	x_offset = screen_center_x + index * CARD_WIDTH - total_width/2
	animate_card_to_position(player_hand[index], Vector2(x_offset, HAND_Y_POS))

func animate_card_to_position(card: Card, new_position: Vector2) ->void:
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.3)
