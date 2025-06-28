extends MatchPlayer
class_name AI

@onready var mana_p_1: Sprite2D = $ManaP1
@onready var mana_p_2: Sprite2D = $ManaP2
@onready var mana_g: Sprite2D = $ManaG
@onready var GM: GameManager = self.get_parent()
@onready var game_actions: GameActions = self.get_parent().get_node("GameActions")
@onready var ai_slot: Node = get_node("../CardSlotManager/AISlot")

var big_mana_AI := 1
var small_mana_AI := 2
var hand : 
	get: return self.get_node("PlayerHand")

const MANA_GRANDE = preload("res://assets/mana/Mana Grande.png")
const MANA_PEQUENA = preload("res://assets/mana/Mana Pequena.png")

func _ready() -> void:
	self.mana_texture()
	self.mana_scale()
	self.mana_position()
	GM.ai_turn_started.connect(_start_ai_turn)
	

func mana_texture():
	mana_p_1.texture = MANA_PEQUENA
	mana_p_2.texture = MANA_PEQUENA
	mana_g.texture = MANA_GRANDE
	
func mana_scale():
	mana_p_1.scale = Vector2(0.12, 0.12)
	mana_p_2.scale = Vector2(0.12, 0.12)
	mana_g.scale = Vector2(0.13, 0.13)

func mana_position():
	#mana_p_1.position =  Vector2(800, 100) 
	#mana_p_2.position = Vector2(800, 215)
	#mana_g.position = Vector2(810, 360)
	mana_g.position = Vector2(765, 340)
	mana_g.rotation_degrees = 170
	mana_g.flip_h = true
	mana_p_1.position =  Vector2(790, 190)
	mana_p_1.rotation_degrees = 165
	mana_p_1.flip_h = true
	mana_p_2.position = Vector2(870, 280)
	mana_p_2.rotation_degrees = 195
	mana_p_2.flip_h = true

func update_mana_visual(available_small_mana, available_big_mana):
	if available_small_mana != 2 or not available_big_mana:
		if not available_big_mana:
			change_mana_visibility(mana_g, false)

		if available_small_mana == 1:
			change_mana_visibility(mana_p_1, false)
		elif available_small_mana == 0:
			change_mana_visibility(mana_p_1, false)
			change_mana_visibility(mana_p_2, false)
	else: #mana inteira
		change_mana_visibility(mana_p_1, true)
		change_mana_visibility(mana_p_2, true)
		change_mana_visibility(mana_g, true)

func change_mana_visibility(mana: Sprite2D, turn_visible: bool) -> void:
	if turn_visible:
		mana.modulate.a = 1.0
	else: # turn "invisible"
		mana.modulate.a = 0.25

func reset_mana():
	self.big_mana_AI = 1
	self.small_mana_AI  = 2
	self.update_mana_visual(small_mana_AI, big_mana_AI)
	
func has_full_mana() -> bool:
	if big_mana_AI == 1 and small_mana_AI == 2:
		return true
	else:
		return false

func use_mana(big_mana: int, small_mana: int):
	if self.big_mana_AI >= big_mana and self.small_mana_AI >= small_mana:
		self.big_mana_AI -= big_mana
		self.small_mana_AI -= small_mana
		self.update_mana_visual(small_mana_AI, big_mana_AI)
	else: #aprimorar essa parte?
		if big_mana == 0 and self.big_mana_AI and self.small_mana_AI < small_mana:
			if self.small_mana_AI + 1 >= small_mana: #troca uma mana grande por uma pequena
				self.small_mana_AI += 1
				self.big_mana_AI = 0
				self.small_mana_AI -= small_mana
				self.update_mana_visual(small_mana_AI, big_mana_AI)
				
func can_use_mana(big_mana: int, small_mana: int):
	if self.big_mana_AI >= big_mana and self.small_mana_AI >= small_mana:
		return true
	else:
		if big_mana == 0 and self.big_mana_AI and self.small_mana_AI < small_mana:
			if self.small_mana_AI + 1 >= small_mana: #troca uma mana grande por uma pequena
				return true
		return false

func _start_ai_turn():
	if GameSettings.ai_difficulty == "easy":
		self.easy_medium_ai_difficulty(true)
	elif GameSettings.ai_difficulty == "medium":
		self.easy_medium_ai_difficulty(false)
	elif GameSettings.ai_difficulty == "hard":
		self.hard_ai_difficulty()
	else: 
		print("Dificuldade inexistente")

	
func easy_medium_ai_difficulty(play_first_card: bool):
	var play_again = randi_range(0, 1) 

	if not hand.player_hand.size() == 0:
		await get_tree().create_timer(1, false).timeout #pensando
		place_card_AI(play_first_card)
		if self.big_mana_AI or self.small_mana_AI == 2 and hand.player_hand.size() == 0:
			if play_first_card: #easy AI sometimes play once
				if play_again:
					await get_tree().create_timer(1, false).timeout #pensando
					place_card_AI(play_first_card)
			else:
				await get_tree().create_timer(1, false).timeout #pensando
				place_card_AI(play_first_card)
		await get_tree().create_timer(3, false).timeout
		GM.get_node("Clock")._on_button_down()
	else:
		await get_tree().create_timer(1, false).timeout
		GM.get_node("Clock")._on_button_down()
	
func place_card_AI(play_first_card: bool):
	var card_placed = false
	var correct_slot = null
	
	if not play_first_card:
		hand.player_hand.sort_custom(func(a: Card, b: Card): return a.rank > b.rank)
		
	var card_ace = hand.player_hand[-1]
	
	if card_ace.type == "ACE":
		hand.remove_card_from_hand(card_ace)
		correct_slot = ai_slot.get_node(card_ace.color)
		card_placed = game_actions.try_place_card(card_ace, correct_slot)
		#print("As foi jogado? ", card_placed)
		
	else:
		for card in hand.player_hand:
			hand.remove_card_from_hand(card)
			correct_slot = ai_slot.get_node(card.color)
			card_placed = game_actions.try_place_card(card, correct_slot)
			if not card_placed:
				#print("IA não conseguiu encontrar um slot para a carta ", card.name, " ", correct_slot.name)
				pass
			else:
				#print("A carta foi jogada: ", card.name)
				break #already played
				
	if not card_placed:
		for card in hand.player_hand:
			hand.remove_card_from_hand(card)
			correct_slot = ai_slot.get_node("QUARTZ")
			card_placed = game_actions.try_place_card(card, correct_slot)
			if card_placed:
				print("A carta foi jogada: ", card.name)
				break
			 
	if not card_placed:
		print("IA não conseguiu jogar nenhuma carta, nem no slot QUARTZ")
			
			
	
func hard_ai_difficulty():
	var time_used = randi_range(1, 5) 
	if not hand.player_hand.size() == 0:
		await get_tree().create_timer(time_used, false).timeout #pensando
		self.decide_best_action()
		if self.big_mana_AI or self.small_mana_AI == 2 and hand.player_hand.size() == 0:
			await get_tree().create_timer(1, false).timeout 
			self.decide_best_action()
		
		await get_tree().create_timer(1, false).timeout
		GM.get_node("Clock")._on_button_down()
	else:
		await get_tree().create_timer(1, false).timeout
		GM.get_node("Clock")._on_button_down()
	
func decide_best_action():
	var best_score = -1000000 
	var best_action = null  # Armazenará a melhor ação (e.g., {"type": "play_card", "card": card, "slot": slot})
	
	# --- 1. AVALIAR JOGAR UMA CARTA ---
	for card in hand.player_hand:
		# Tenta jogar a carta em slots de cor ou QUARTZ
		var potential_slots = get_potential_slots(card)
		for slot in potential_slots:
			var simulated_cost = calculate_play_cost(card, slot)
			if can_use_mana(simulated_cost.large, simulated_cost.small):
				# Simula a jogada e calcula o "score" potencial
				var current_score = evaluate_play_card(card, slot, simulated_cost)
				if current_score > best_score:
					best_score = current_score
					best_action = {"type": "play_card", "card": card, "slot": slot, "cost": simulated_cost}
					
		# --- 2. AVALIAR FUSÃO DE CARTAS (NOVO CÓDIGO) ---
	var possible_merges = find_possible_merges()
	for merge_pair in possible_merges:
		var card1 = merge_pair[0]
		var card2 = merge_pair[1]
		
		var merge_score = evaluate_merge_cards(card1, card2)
		if merge_score > best_score:
			print("Melhor score atual (via fusão): ", merge_score)
			best_score = merge_score
			best_action = {"type": "merge_cards", "cards": [card1, card2]}
			
	# --- 3. AVALIAR DESCARTAR E COMPRAR ---
	var discard_cost = {"large": 0, "small": 2}
	if can_use_mana(discard_cost.large, discard_cost.small):
		# Descartar e comprar é uma boa opção se não houver jogadas boas e a mão for ruim.
		# Por simplicidade inicial, podemos dar um "score" fixo ou baseado na mão atual.
		var discard_score = evaluate_discard_and_draw()
		if discard_score > best_score: # Se for melhor que a melhor jogada de carta
			best_score = discard_score
			best_action = {"type": "discard_and_draw", "cost": discard_cost}
			
	
	 # --- Executar a Melhor Ação ---
	if best_action:
		print(str("IA decidiu: ", best_action.type, " com score: ", best_score))
		execute_action(best_action)
	else:
		print("IA não encontrou nenhuma ação ideal. Passando a vez para comprar uma carta.")


func get_potential_slots(card: Card) -> Array:
	var potential_slots = []
	var ai_slots_nodes = ai_slot.get_children() # Assumindo que ai_slot.get_children() são os slots do campo da IA
	var can_play
	for slot_node in ai_slots_nodes:
		can_play = game_actions.can_place_card(card, slot_node, true) #passando que é IA 
		if can_play.can_place:
			potential_slots.append(slot_node)
	return potential_slots
	
func calculate_play_cost(card: Card, target_slot: Node) -> Dictionary:
	var can_place_card = game_actions.can_place_card(card, target_slot, true)
	var cost = {"large": can_place_card.cost_big, "small": can_place_card.cost_small}
	return cost
	
func evaluate_play_card(card: Card, target_slot: Node, cost: Dictionary) -> float:
	var score = 0.0
	
	score += float(card.rank)

	var current_slot_value = 0
	for card_in_slot in target_slot.slot_pile:
		current_slot_value += card_in_slot.rank
		
	var projected_slot_value = current_slot_value + card.rank
	
	if target_slot.name.to_upper() != "QUARTZ":
		if projected_slot_value > 15:
			score -= 150.0 # Penalidade severa, invalida o slot
		elif projected_slot_value == 15:
			score += 200.0 
		elif projected_slot_value == 14:
			score += 80.0
		elif projected_slot_value == 13:
			score += 60.0 
		elif projected_slot_value <= 10 and projected_slot_value > 0: # Bônus menor para valores razoáveis
			score += 8.0 * (projected_slot_value / 10.0) # Escala o bônus de 0 a 10
	else: 
		if projected_slot_value == 15:
			score += 200.0 
		elif projected_slot_value == 14:
			score += 80.0
		
		
	if card.type == "ACE" and target_slot.name.to_upper() == card.color.to_upper():
		# Se o slot está vazio, jogar um ACE é um bom começo
		if target_slot.slot_pile.is_empty():
			score += 20.0
		else: 
			score += 10.0
		
	if card.type in ["HIGH", "MID", "LOW"]:
		var current_types = target_slot.slot_pile.map(func(c): return c.type)
		if current_types.has("ACE"):
			current_types.erase("ACE")
		current_types.append(card.type)
		current_types.sort()
		if current_types in [["HIGH", "LOW"], ["LOW", "LOW", "MID"], ["MID", "MID"]]:
			if projected_slot_value == 15:
				score += 500.0 
			elif projected_slot_value == 14:
				score += 150.0
			elif projected_slot_value == 13:
				score += 100.0
			elif projected_slot_value == 12:
				score += 20.0
			else:
				score -= 10
		
	return score
	
func evaluate_discard_and_draw() -> float:
	# Custo: 2 mana pequena
	# Benefício: Chance de uma carta melhor.
	# Penalidade: Perde uma carta atual.

	# Isso é muito subjetivo e depende do estado do jogo.
	# Sugestões:
	# - Dar um score baixo e fixo (e.g., 2.0).
	# - Calcular um "valor médio" das cartas da IA e se todas forem "ruins", dar um score mais alto.
	# - Penalizar se a mão já está boa.
	
	var score = -5.0
	if hand.player_hand.size() > 0:
		var unplayable_cards = 0
		for card in hand.player_hand:
			if get_potential_slots(card).is_empty():
				unplayable_cards += 1
		if unplayable_cards == hand.player_hand.size(): # Todas as cartas são injogáveis
			score += 25.0
		elif unplayable_cards > 1:
			score += 5
			
	return score
	
func find_possible_merges() -> Array:
	var possible_merges = []
	var current_hand = hand.player_hand
	
	if current_hand.size() < 2:
		return possible_merges
		
	# Loop aninhado para verificar todos os pares de cartas sem repetir
	for i in range(current_hand.size()):
		for j in range(i + 1, current_hand.size()):
			var card1 = current_hand[i]
			var card2 = current_hand[j]

			var pair = [card1.rank, card2.rank]
			pair.sort() # Ordena para comparar com os pares válidos

			# Supondo que você tenha os pares válidos definidos como no exemplo anterior
			# Ex: const VALID_PAIRS = [[2, 2], [2, 5], [2, 8]]
			if pair in hand.VALID_PAIRS: 
				possible_merges.append([card1, card2])
				
	return possible_merges	
	
# Avalia o quão boa é uma ação de fusão
func evaluate_merge_cards(card1: Card, card2: Card) -> float:
	var score = 0.0
	
	score += 5.0 # Penalidade por diminuir o tamanho da mão

	# 3. Análise Estratégica: A fusão resolveu um problema?
	# Se as cartas antigas eram "inúteis" (não podiam ser jogadas em bons slots),
	# a fusão é muito mais valiosa.
	var card1_slots = get_potential_slots(card1)
	var card2_slots = get_potential_slots(card2)

	if card1_slots.is_empty():
		score += 15.0 # Bônus enorme por se livrar de uma carta inútil
	if card2_slots.is_empty():
		score += 15.0 # Bônus enorme

	var new_value = card1.rank + card2.rank
	
	var new_color
	if card1.rank > card2.rank:
		new_color = card1.color
	else:
		new_color = card2.color
	
	var new_card = Card.new_card(new_color, new_value)
	
	var new_card_slots = get_potential_slots(new_card)
	
	var best_score = 0
	for slot in new_card_slots:
			var simulated_cost = calculate_play_cost(new_card, slot)
			if can_use_mana(simulated_cost.large, simulated_cost.small):
				var current_score = evaluate_play_card(new_card, slot, simulated_cost)
				if current_score > best_score:
					best_score = current_score
	
	score += best_score
	
	return score

	
func execute_action(action: Dictionary):

	if action.type == "play_card":
		var card_to_play: Card = action.card
		var target_slot: Node = action.slot
	
		hand.remove_card_from_hand(card_to_play)
		
		var success = game_actions.try_place_card(card_to_play, target_slot)
		if not success:
			print("ERRO CRÍTICO: IA tentou jogar carta, mas try_place_card falhou! ", card_to_play.name, " em ", target_slot.name)
			
			
	elif action.type == "discard_and_draw":
		print("IA decidiu descartar uma carta e comprar outra.")
		var card_to_discard: Card
		
		for card_in_hand in hand.player_hand:
			print(get_potential_slots(card_in_hand))
			if get_potential_slots(card_in_hand).is_empty() or get_potential_slots(card_in_hand)[0].name == "QUARTZ":
				card_to_discard = card_in_hand
				break
				
		if hand.player_hand.size() > 0:
			hand.remove_card_from_hand(card_to_discard)
			game_actions.try_discard_card(card_to_discard)
			print(str("IA descartou: ", card_to_discard.name))
			
	elif action.type == "merge_cards":
		var cards_to_merge: Array = action.cards
		var card1 = cards_to_merge[0]
		var card2 = cards_to_merge[1]

		print(str("IA decidiu fundir: ", card1.name, " com ", card2.name))

		# Chama a função de fusão que criamos anteriormente no script da Mão (Hand)
		# Supondo que a função se chame 'merge_cards_logic' e esteja no script 'hand'
		hand.attempt_merge(cards_to_merge)
		self.decide_best_action()
