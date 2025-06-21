extends Node2D
class_name GameActions
# Here each player action will have a function, connected by signal 

var screen_size: Vector2
var mouse_pos: Vector2

signal score_updated(score_change_value, color)

@onready var GM: GameManager = $".."

@onready var deck: Node2D = $"../Deck"
var deck_pile:
	get: return deck.deck_pile

@onready var card_manager: Node2D = $"../CardManager"
var highlighted_card:
	get: return card_manager.highlighted_card
var card_being_dragged: Card = null

@onready var card_slot_manager: Node2D = $"../CardSlotManager"
var card_slot_hovered:
	get: return card_slot_manager.card_slot_hovered

@onready var discard_deck: Node2D = $"../DiscardPile"
var discard_pile_hovered:
	get: return discard_deck.discard_pile_hovered

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
	if card_being_dragged:
		mouse_pos = get_global_mouse_position()
		mouse_pos.x = clamp(mouse_pos.x, 0, screen_size.x)
		mouse_pos.y = clamp(mouse_pos.y, 0, screen_size.y)
		card_being_dragged.position = mouse_pos


func _input(event: InputEvent) -> void:
	if GM.game_started:
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
		if card_slot_hovered and GM.current_player == player:
			try_place_card(card_being_dragged, card_slot_hovered)
		elif discard_pile_hovered and GM.current_player == player:
			try_discard_card(card_being_dragged)
		else: # Return card to hand
			player_hand.add_card_to_hand(highlighted_card)
		card_being_dragged = null


func try_place_card(card: Card, slot: CardSlot) -> bool:
	var is_AI := (GM.current_player != player)
	
	var allowed_slot: bool
	if is_AI:
		allowed_slot = slot.get_parent().name == "AISlot"
	else:
		allowed_slot = slot.get_parent().name == "PlayerSlot"
	
	# Regras de combinação por tipo
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
			["HIGH", "LOW"]: "big"
		}
	}

	var is_valid_combination := false
	var cost_big_mana := 0
	var cost_small_mana := 0

	if card.type in combination_rules:
		var current_types := slot.slot_pile.map(func(c): return c.type)
		if current_types.has("ACE"):
			current_types.erase("ACE")
		current_types.append(card.type)
		current_types.sort()
		var type_rules = combination_rules[card.type]
		if type_rules.has(current_types):
			is_valid_combination = true
			match type_rules[current_types]:
				"small":
					cost_small_mana = 1
				"big":
					cost_big_mana = 1

	elif card.type == "ACE":
		is_valid_combination = true
		cost_small_mana = 1


	# Condições para jogar a carta
	var rules := [
		card.color == slot.color or slot.color == "QUARTZ",
		#card in GM.current_player.hand.player_hand,
		is_valid_combination,
		allowed_slot
	]

	var can_play = rules.reduce(func(a, b): return a and b)
	var can_use_mana = can_play and GM.current_player.try_use_mana(cost_big_mana, cost_small_mana)
	var score_change_value = card.rank
	
	print(allowed_slot)
	print(is_valid_combination)
	print(can_play)
	print(can_use_mana)
	print("Card color ", card.color)
	print("Slot color ", slot.color)
	
	if can_use_mana:
		slot.add_card_to_slot(card)
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
	#if is_AI:
		#print(allowed_slot)
		#print(is_valid_combination)
		#print(can_play)
		#print(can_use_mana)
		#print("Card color ", card.color)
		#print("Slot color ", slot.color)


func try_discard_card(card: Card) -> void:
	if GM.current_player.try_use_mana(0, 2) and deck_pile:
		discard_deck.discard_card(card) #responsabilidade do discard_pile
		self.buy_card()
	else: # Return card to hand
		if GM.current_player == player:
			player_hand.add_card_to_hand(card)
		else:
			AI_hand.add_card_to_hand(card)


func buy_card() -> void:
	var new_card = deck.buy()
	if GM.current_player == player:
		new_card.flip()
		new_card.get_node("Area2D/CollisionShape2D").disabled = false
		#player_hand.animation_speed = 0.3
		player_hand.add_card_to_hand(new_card)
		#player_hand.animation_speed = 0.2
	else:
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
	

#func place_card(card: CardUI, slot: CardSlotSystem, callback: Callable):
	## checar tipo da coluna/carta
	#var parent = slot.slot_node.get_parent()
	#var type_slot
	#if slot.slot_node is Slot:
		#type_slot = slot.slot_node.type_slot
	#else:
		#type_slot = null
	#var column_type
	#if parent.has_method("get_column_type"):
		#column_type = parent.get_column_type()
		#
	## Garantir que o jogador só pode jogar nos seus próprios slots
	#var current_player = self.gm.turn  
	#var allowed_slots = []
	#if current_player.id == self.gm.get_local_player().id:  # Player 1
		#print("VOCE COME")
		#allowed_slots = ["Soldado_Down", "General_Down"]
	#
	#var is_valid_combination = false
	#var custo_big_mana = 0
	#var custo_small_mana = 0
	#
	#if card.type == "Soldado": 
		#var existing_cards = slot.cards  # Pega as cartas já no slot
		#var current_ranks = [] 
		#
		#for c in existing_cards:
			#current_ranks.append(c.rank)  
			#
		#current_ranks.append(card.rank)  
		#
		#current_ranks.sort()
		#
		#if card.rank == "Alto":
			#if current_ranks == ["Alto"]:
				#is_valid_combination = true
			#elif current_ranks == ["Alto", "Baixo"]:
				#is_valid_combination = true
			#custo_big_mana = 1
			#
		#elif card.rank == "Medio":
			#if current_ranks == ["Medio"]:
				#is_valid_combination = true
			#elif current_ranks == ["Medio", "Medio"]:
				#is_valid_combination = true
			#elif current_ranks == ["Baixo", "Medio"]:
				#is_valid_combination = true
			#elif current_ranks == ["Baixo", "Baixo","Medio"]:
				#is_valid_combination = true
			#custo_big_mana = 1
			#
		#elif card.rank == "Baixo":
			#if current_ranks == ["Baixo"]:
				#is_valid_combination = true
				#custo_small_mana = 1
			#elif current_ranks == ["Alto", "Baixo"]:
				#is_valid_combination = true
				#custo_big_mana = 1
			#elif current_ranks == ["Baixo", "Medio"]:
				#is_valid_combination = true
				#custo_small_mana = 1
			#elif current_ranks == ["Baixo", "Baixo"]:
				#is_valid_combination = true
				#custo_small_mana = 1
			#elif current_ranks == ["Baixo", "Baixo","Medio"]:
				#is_valid_combination = true
				#custo_small_mana = 1
			#
	#else:
		#custo_small_mana = 1
		#is_valid_combination = true
	#print("Custo big mana: ", custo_big_mana)
	#print("Custo small mana: ", custo_small_mana)
		#
	## menos performance, mas evita o inferno de if-else's
	#var type_rules = [
		#card.type == "Soldado" and type_slot in ["Soldado_Top", "Soldado_Down"],
		#card.type == "General" and type_slot in ["General_Top", "General_Down"],
		#card.type == "Lider" and type_slot == "Lider",
	#]
#
	#
	#var rules = [
		#(card.type_color == column_type or column_type == "Quartzo"),
		#type_rules.reduce(func(a, b): return a or b),
		#card in self.gm.turn.hand.card_slot.cards,
		#type_slot in allowed_slots,
		#is_valid_combination,
	#]
	## Imprimir as regras
	#print("Player small mana: ", self.gm.turn.small_mana_player)
	#print("Player big mana: ", self.gm.turn.big_mana_player)
	#var can_use_mana = false
	#if rules.reduce(func(a, b): return a and b):
		#can_use_mana = self.gm.turn.try_use_mana(custo_big_mana, custo_small_mana)
	#
	#print("Depois Player small mana: ", self.gm.turn.small_mana_player)
	#print("Depois Player big mana: ", self.gm.turn.big_mana_player)
	#
	#if can_use_mana:
		#GameEvents.on_mana_spend.emit(self.gm.turn, self.gm.turn.small_mana_player, self.gm.turn.big_mana_player > 0)
		#if card.type == "Soldado" and (slot.slot_node.type_slot in ["Soldado_Top", "Soldado_Down"]):
			#var power = int(card.get_node("Power").text)
			#if current_player == self.gm.get_local_player():
				#slot.slot_node.somador.adicionar_pontos(power)
			#else:
				#slot.slot_node.somador.adicionar_pontos(-power)
		#if card.type == "General" and (slot.slot_node.type_slot in ["General_Top", "General_Down"]):
				#if current_player == self.gm.get_local_player():
					#slot.slot_node.somador.adicionar_pontos(1)
				#else:
					#slot.slot_node.somador.adicionar_pontos(-1)
		#callback.call()
	#card.parent_slot.card_slot.position_cards()


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
