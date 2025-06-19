extends Node2D
class_name PlayerHand

const TRUE_CARD_WIDTH: float = 148.0
const CARD_WIDTH: float = TRUE_CARD_WIDTH * 1.10
const TRUE_CARD_HEIGHT: float = 200.0
const CARD_HEIGHT: float = TRUE_CARD_HEIGHT * 1.10
const HAND_Y_POS: float = 1080 + TRUE_CARD_HEIGHT/6 # 1 terço a mostra
const SHOWN_HAND_Y_POS: float = 1080 - CARD_HEIGHT/2

var player_hand: Array[Card] = []
var screen_center_x: float
var total_width: float
var x_offset: float
var animation_speed: float = 0.2
var hand_hovered: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area2D/CollisionShape2D.shape.set_size(Vector2(0, 0))
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
	update_hand_area_size()
	for index in player_hand.size():
		update_card_position(index)
		update_hand_area_size()


func update_card_position(index: int) -> void:
	total_width = (player_hand.size() -1) * CARD_WIDTH
	x_offset = screen_center_x + index * CARD_WIDTH - total_width/2
	var new_position := Vector2(x_offset, SHOWN_HAND_Y_POS if hand_hovered else HAND_Y_POS)
	animate_card_to_position(player_hand[index], new_position)


func animate_card_to_position(card: Card, new_position: Vector2) ->void:
	var tween = card.create_tween()
	tween.tween_property(card, "position", new_position, animation_speed)


func _on_area_2d_mouse_entered() -> void:
	hand_hovered = true
	update_hand_area_size()
	show_hand()


func _on_area_2d_mouse_exited() -> void:
	hand_hovered = false
	update_hand()


func show_hand() -> void:
	for card in player_hand:
		var new_card_pos := Vector2(card.position.x, SHOWN_HAND_Y_POS)
		animation_speed = 0.1
		animate_card_to_position(card, new_card_pos)
	animation_speed = 0.2


func update_hand_area_size() -> void:
	var new_size: Vector2
	if not player_hand:
		$Area2D/CollisionShape2D.shape.set_size(Vector2(0,0))
	elif hand_hovered:
		new_size = Vector2(CARD_WIDTH * player_hand.size(), CARD_HEIGHT * 2)
	else:
		new_size = Vector2(CARD_WIDTH * player_hand.size(), 2*TRUE_CARD_HEIGHT/3)
	$Area2D/CollisionShape2D.shape.set_size(new_size)
