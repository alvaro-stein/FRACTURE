extends Node2D

var standard_z_index = self.z_index
var screen_size: Vector2
var mouse_pos: Vector2
var card_being_dragged: Card = null
var highlighted_card: Card = null
var last_card_hovered: Card = null
@onready var player_hand: Node2D = $"../PlayerHand"
@onready var deck: Node2D = $"../Deck"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if card_being_dragged:
		mouse_pos = get_global_mouse_position()
		mouse_pos.x = clamp(mouse_pos.x, 0, screen_size.x)
		mouse_pos.y = clamp(mouse_pos.y, 0, screen_size.y)
		card_being_dragged.position = mouse_pos





# Card implementation
func connect_card_signals(card: Card) -> void:
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)


func on_hovered_over_card(card: Card) -> void:
	last_card_hovered = card
	if not highlighted_card:
		highlighted_card = card
		highlight_card(card, true)


func on_hovered_off_card(card: Card) -> void:
	if highlighted_card == card:
		highlighted_card = null
		highlight_card(card, false)
		if last_card_hovered != card:
			highlighted_card = last_card_hovered
			highlight_card(last_card_hovered, true)
		else:
			last_card_hovered = null
	else:
		last_card_hovered = highlighted_card


func highlight_card(card: Card, hovered: bool) -> void:
	if hovered:
		card.scale = Vector2(1.05, 1.05)
		card.z_index = standard_z_index + 1
	else:
		card.scale = Vector2(1, 1)
		card.z_index = standard_z_index
