extends Node2D

var standard_z_index = self.z_index
var screen_size: Vector2
var mouse_pos: Vector2
var card_being_dragged: Card = null
var highlighted_card: Card = null
var last_card_hovered: Card = null
@onready var card_slot_manager: Node2D = $"../CardSlotManager"
var card_slot_hovered:
	get: return card_slot_manager.card_slot_hovered
@onready var player_hand: Node2D = $"../PlayerHand"


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


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and highlighted_card:
		start_drag() if event.pressed else finish_drag()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and highlighted_card:
		if event.pressed:
			highlighted_card.flip()


func start_drag() -> void:
	player_hand.remove_card_from_hand(highlighted_card)
	card_being_dragged = highlighted_card
	highlighted_card.scale = Vector2(1, 1)


func finish_drag() -> void:
	highlighted_card.scale = Vector2(1.05, 1.05)
	if card_being_dragged:
		if card_slot_hovered and card_slot_hovered.is_empty:
			# Then drop the card into the empty card slot
			card_slot_hovered.is_empty = false
			card_being_dragged.position = card_slot_hovered.position
			card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
		else:
			player_hand.add_card_to_hand(highlighted_card)
		card_being_dragged = null


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
