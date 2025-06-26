extends Node2D
class_name GameActions
# Here each player action will have a function, connected by signal 

signal card_right_clicked
signal score_updated(score_change_value, color)

const CARD_LAYER := 2 # Layer 2, valor 2
const SLOT_LAYER := 4 # Layer 3, valor 4 # Pois são potencias de 2
const DISCARD_PILE_LAYER := 8 # Layer 4, valor 8

var screen_size: Vector2
var mouse_pos: Vector2
var card_held: Card = null

@onready var GM: GameManager = $".."

@onready var deck: Node2D = $"../Deck"
var deck_pile:
	get: return deck.deck_pile

@onready var discard_deck: Node2D = $"../DiscardPile"

@onready var player: MatchPlayer = $"../Player"
var player_hand:
	get: return player.get_node("PlayerHand")

@onready var AI: MatchPlayer = $"../AI"
var AI_hand:
	get: return AI.get_node("PlayerHand")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.drag_card()


func drag_card() -> void:
	if card_held:
		mouse_pos = get_global_mouse_position()
		mouse_pos.x = clamp(mouse_pos.x, 0, screen_size.x)
		mouse_pos.y = clamp(mouse_pos.y, 0, screen_size.y)
		card_held.position = mouse_pos


# Returns an Array of Dictionaries, each containing a colliding object. Empty if no collision.
func raycast_at_cursor(collision_mask: int) -> Array[Dictionary]:
	# Get the 2D physics space state from the current world.
	var space_state = get_world_2d().direct_space_state
	var mouse_pos = get_global_mouse_position()
	# Create the query parameters object.
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collision_mask = collision_mask
	query.collide_with_areas = true
	# Returns an Array[Dictionary]
	return space_state.intersect_point(query)


func try_get_card() -> Card:
	var results: Array[Dictionary] = raycast_at_cursor(CARD_LAYER)
	var cards: Array = []
	for i in results.size():
		cards.append(results[i].collider.get_parent())
	if cards:
		var card_under_cursor = cards[0]
		for card in cards:
			if card.z_index > card_under_cursor.z_index:
				card_under_cursor = card
		return card_under_cursor
	else:
		return null


func try_get_slot() -> CardSlot:
	var result = raycast_at_cursor(SLOT_LAYER)
	return result[0].collider.get_parent() if result else null


func try_get_discard_pile() -> DiscardPile:
	var result = raycast_at_cursor(DISCARD_PILE_LAYER)
	return result[0].collider.get_parent() if result else null


func _input(event: InputEvent) -> void:
	if GM.game_started:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				card_held = try_get_card()
				if card_held:
					start_drag()
			else:
				finish_drag()
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var highlighted_card = try_get_card()
			emit_signal("card_right_clicked", highlighted_card)
			highlighted_card.flip()


func start_drag() -> void:
	player_hand.remove_card_from_hand(card_held)
	card_held.scale = Vector2(1, 1)


func finish_drag() -> void:
	if card_held:
		card_held.scale = Vector2(1.05, 1.05)
		var card_slot_hovered = try_get_slot()
		var discard_pile_hovered = try_get_discard_pile()
		if card_slot_hovered and GM.current_player == player:
			try_place_card(card_held, card_slot_hovered)
		elif discard_pile_hovered and GM.current_player == player:
			try_discard_card(card_held)
			print("NÃO ESTAVA EM CIMA DO DESCARTE")
		else: # Return card to hand
			print("NÃO ESTAVA EM CIMA DO SLOT")
			player_hand.add_card_to_hand(card_held)
		card_held = null


func try_place_card(card: Card, slot: CardSlot) -> bool:
	var is_AI := (GM.current_player != player)
	var can_place_card = self.can_place_card(card, slot, is_AI) 
	var can_play = can_place_card.can_place
	var cost_big_mana = can_place_card.cost_big
	var cost_small_mana = can_place_card.cost_small
	var score_change_value = card.rank
	
	print("POSSO JOGAR AQUI? ", can_play)
	
	if can_play:
		GM.current_player.use_mana(cost_big_mana, cost_small_mana)
		slot.add_card_to_slot(card, is_AI)
		if is_AI:
			score_change_value *= -1
		emit_signal("score_updated", score_change_value, slot.color)
		return true
	else:
		var hand
		if is_AI:
			hand = AI_hand
		else:
			hand = player_hand
		hand.add_card_to_hand(card)
		return false


func can_place_card(card: Card, slot: CardSlot, is_AI: bool):
	var can_place := {"can_place": false, "cost_big": 0, "cost_small": 0}
	
	var allowed_slot: bool
	if is_AI:
		allowed_slot = slot.get_parent().name == "AISlot"
	else:
		allowed_slot = slot.get_parent().name == "PlayerSlot"
	
	# Regras de combinação por tipo
	var combination = is_valid_combination(card, slot)
	
	can_place.cost_big = combination.cost_big
	can_place.cost_small = combination.cost_small
	# Condições para jogar a carta
	var rules := [
		card.color == slot.color or slot.color == "QUARTZ",
		#card in GM.current_player.hand.player_hand,
		combination.is_valid,
		allowed_slot
	]
	var can_play = rules.reduce(func(a, b): return a and b)
	var can_use_mana = GM.current_player.can_use_mana(can_place.cost_big, can_place.cost_small)
	
	#print(allowed_slot)
	#print(combination.is_valid)
	#print(can_play)
	#print(can_use_mana)
	
	if can_play and can_use_mana:
		can_place.can_place = true
	else: 
		can_place.can_place = false
	return can_place
	

func try_discard_card(card: Card) -> void:
	if GM.current_player.can_use_mana(0, 2) and deck_pile:
		GM.current_player.use_mana(0, 2)
		discard_deck.discard_card(card) #responsabilidade do discard_pile
		self.buy_card()
	else: # Return card to hand
		if GM.current_player == player:
			player_hand.add_card_to_hand(card)
		else:
			AI_hand.add_card_to_hand(card)

func is_valid_combination(card: Card, slot: CardSlot):
	var combination := {"cost_big": 0, "cost_small": 0, "is_valid": false}
	var combination_rules := {
		"HIGH": {
			["HIGH"]: "big",
			["HIGH", "LOW"]: "big"
		},
		"MID": {
			["MID"]: "big",
			["MID", "MID"]: "big",
			["LOW", "MID"]: "big",
			["LOW", "LOW", "MID"]: "big"
		},
		"LOW": {
			["LOW"]: "small",
			["LOW", "LOW"]: "small",
			["LOW", "MID"]: "small",
			["LOW", "LOW", "MID"]: "small",
			["LOW", "LOW", "MID"]: "small",
			["HIGH", "LOW"]: "big"
		}
	}

	if card.type in combination_rules:
		var current_types := slot.slot_pile.map(func(c): return c.type)
		if current_types.has("ACE"):
			current_types.erase("ACE")
		current_types.append(card.type)
		current_types.sort()
		var type_rules = combination_rules[card.type]
		if type_rules.has(current_types):
			combination.is_valid = true
			match type_rules[current_types]:
				"small":
					combination.cost_small = 1
				"big":
					combination.cost_big= 1
					
	elif card.type == "ACE":
		combination.is_valid = true
		combination.cost_small = 1
	
	return combination

func buy_card() -> void:
	var new_card = deck.buy()
	if GM.current_player == player:
		new_card.flip()
		new_card.get_node("Area2D/CollisionShape2D").disabled = false
		#player_hand.animation_speed = 0.3
		player_hand.add_card_to_hand(new_card)
		#player_hand.animation_speed = 0.2
	else:
		#new_card.flip() #adicionado para testes
		AI_hand.add_card_to_hand(new_card)




#func _init(game_manager: GameManager) -> void:
	#self.GM = game_manager
	#GameEvents.on_buy_button_pressed.connect(buy_extra_card)
	#GameEvents.on_end_turn_button_pressed.connect(end_turn)
	#GameEvents.on_card_placing.connect(place_card)
	#GameEvents.on_card_highlighting.connect(highlight_card)
	#GameEvents.on_card_dragging.connect(drag_card)
	

#func highlight_card(card: CardUI, callback: Callable):
	#if card.parent_slot is Slot or card.parent_slot is Hand:
		#callback.call()
		#
#func drag_card(card: CardUI, callback: Callable):
	#if card.parent_slot is Hand:
		#callback.call()
	




#func use_ability(card: CardUI):
	#if card.ability:
		#self.gm.turn.try_use_mana(card.big_cost, card.small_cost)
	## verify if the card has an ability and call its function
	
	
#func replace_card(new_card: CardUI, slot: CardSlotSystem, old_card: CardUI):
	#if new_card in self.gm.turn.hand.get_children():
		#if slot.remove_card(old_card):
			#if self.gm.turn.try_use_mana(new_card.big_cost, new_card.small_cost):
				#self.gm.discard_deck.add_child(old_card)
				#slot.add_card(new_card)
				#return true
			#else:
				#print("Error: Insufficient mana")
				#return false
		#else:
			#print("Error: Chosen card is not in the slot")
			#return false
	#else:
		#print("Error: Card not found in hand")
		#return false



#func synthesize_cards(card1: CardUI, card2: CardUI): #3 states
	#var possible_values = [2, 5, 8]
	#if (card1.power.text == "G") or (card2.power.text == "G"):
		#print("Error in systhesize cards, card impossible to synthesize")
		#return false
		#
	#if int(card1.power.text) != 2 and int(card2.power.text) != 2:
		#print("Error in synthesize cards, no card with power equals 2")
		#return false 
	#
	#if int(card1.power.text) == 2:
		#if !int(card2.power.text) in possible_values:
			#print("Error in systhesize cards, card impossible to synthesize")
			#return false
		#else:
			#return true
	#elif int(card2.power.text) == 2: 
		#if !int(card1.power.text) in possible_values: 
			#print("Error in systhesize cards, card impossible to synthesize")
		#else:
			#return true

#func end_turn(callback: Callable):
	#if gm.buy_deck.card_slot.cards.is_empty():
		#print("Baralho vazio!")
		##if gm.turn == gm.players[-1]: 
		#print("Último turno encerrado, fim do jogo!")
		#GameEvents.on_game_over.emit()
	#else:
		#if gm.turn == gm.get_local_player():
			#callback.call()
		#else:
			#print("Não é seu turno!")
