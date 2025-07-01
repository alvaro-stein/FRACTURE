extends Node2D
class_name PlayerHand 

const TRUE_CARD_WIDTH: float = 148.0
const CARD_WIDTH: float = TRUE_CARD_WIDTH * 1.1
const TRUE_CARD_HEIGHT: float = 200.0
const CARD_HEIGHT: float = TRUE_CARD_HEIGHT * 1.1
const HAND_Y_POS: float = 1080 + TRUE_CARD_HEIGHT/6 # 1 terço a mostra
const SHOWN_HAND_Y_POS: float = 1080 - CARD_HEIGHT/2
const VALID_PAIRS = [[2, 2], [2, 5], [2, 8], [5, 2], [8, 2]]

@onready var game_actions = get_node("../../GameActions")
@onready var card_manager = get_node("../../CardManager")

var player_hand: Array[Card] = []
var selected_cards: Array[Card] = []
var screen_center_x: float
var total_width: float
var x_offset: float
var animation_speed: float = 0.2
var hand_hovered: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area2D/CollisionShape2D.shape.set_size(Vector2(0, 0))
	screen_center_x = get_viewport_rect().size.x / 2
	if self.get_parent().name == "Player":
		game_actions.card_right_clicked.connect(_on_card_right_clicked)


func remove_card_from_hand(card: Card) -> void:
	if card in player_hand:
		var index = player_hand.find(card)
		player_hand.remove_at(index)
		card.card_set_z_index(card.z_index-1)
		update_hand()


func add_card_to_hand(card: Card) -> void:
	if self.get_parent().name == "AI":
		card.rotation_degrees = 180
	if card not in player_hand:
		player_hand.append(card)
		card.card_set_z_index(card.z_index+1)
		self.update_hand()


func update_hand() -> void:
	update_hand_area_size()
	for index in player_hand.size():
		update_card_position(index)
		update_hand_area_size()


func update_card_position(index: int) -> void:
	total_width = (player_hand.size() -1) * CARD_WIDTH
	x_offset = screen_center_x + index * CARD_WIDTH - total_width/2
	var new_position := Vector2(x_offset, SHOWN_HAND_Y_POS if hand_hovered else HAND_Y_POS)
	if self.get_parent().name == "AI":
		new_position = mirror_pos(new_position)
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
		if self.get_parent().name == "AI":
			new_card_pos = mirror_pos(new_card_pos)
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

func mirror_pos(pos: Vector2):
	pos.y = (pos.y - 1080) * (-1)
	return pos

func _on_card_right_clicked(card: Card):
	if card in selected_cards:
		selected_cards.erase(card)
		card.flip(true)
		return
	# Adiciona a carta à lista de seleção e atualiza seu visual
	selected_cards.append(card)
	
	card.flip(true)
	
	for card_selected in selected_cards:
		if is_instance_valid(card_selected) and card_selected not in player_hand:
			selected_cards.erase(card_selected)
	
	if selected_cards.size() == 2:
		attempt_merge(selected_cards)
		

# Lógica principal da fusão
func attempt_merge(selected_cards):
	var card1 = selected_cards[0]
	var card2 = selected_cards[1]
	
	var val1 = card1.rank
	var val2 = card2.rank
	
	# Para a verificação ser mais fácil, criamos um par e o ordenamos
	var pair = [val1, val2]
	
	if pair in VALID_PAIRS:
		merge_cards(card1, card2)
	else:
		reset_selection()

func merge_cards(card1: Card, card2: Card):
	# Calcula o novo valor
	var new_value = card1.rank + card2.rank
	
	var new_color
	if card1.rank >= card2.rank:
		new_color = card1.color
	else:
		new_color = card2.color

	var new_card = Card.new_card(new_color, new_value)
	
	self.player_hand.erase(card1)
	self.player_hand.erase(card2)
	
	new_card.position = self.get_parent().position
	
	card_manager.add_child(new_card)
	
	if self.get_parent().name == "Player":
		new_card.get_node("Area2D/CollisionShape2D").disabled = false
		call_deferred("setup_new_front", new_card, GameSettings.race)
		new_card.flip(true)
	else:
		var AI_race = "OPH" if GameSettings.race == "VIR" else "VIR"
		call_deferred("setup_new_front", new_card, AI_race)
	
	self.add_card_to_hand(new_card)
	
	card1.queue_free()
	card2.queue_free()

	selected_cards.clear()

func reset_selection():
	for card in selected_cards:
		if is_instance_valid(card):
			card.flip(false)
	
	selected_cards.clear()

func setup_new_front(card, race):
	card.get_node("Front").texture = load("res://assets/sprites/NewCards/%s_%s.png" %[card.color+str(card.rank), GameSettings.race])
	card.get_node("Front").texture = load("res://assets/sprites/NewCards/%s_%s.png" %[card.color+str(card.rank), race])
