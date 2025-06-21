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
	mana_p_1.position =  Vector2(800, 100) 
	mana_p_2.position = Vector2(800, 215)
	mana_g.position = Vector2(810, 360)

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
	print("AI começa o turno")
	
	if not hand.player_hand.size() == 0:
		await get_tree().create_timer(1).timeout #pensando
		self.place_card_AI()
	
	else:
		print("IA não tem cartas na mão para jogar. Passando o turno.")
		await get_tree().create_timer(1).timeout
		GM._on_end_turn()
		
	await get_tree().create_timer(1).timeout
	GM._on_end_turn() #gambiarra só pra AI terminar o turno

func place_card_AI():
	var card_placed = false
	
	#while not card_placed:
	hand.player_hand.shuffle()
	for card in hand.player_hand:
		#var random_index = randi_range(0, hand.player_hand.size() - 1)
		#var card : Card = self.hand.player_hand[random_index]
		hand.remove_card_from_hand(card)
		var correct_slot = ai_slot.get_node(card.color)
		card_placed = game_actions.try_place_card(card, correct_slot)
		if not card_placed:
			print("IA não conseguiu encontrar um slot para a carta ", card.name, correct_slot.name)
		else:
			break #already played
			
	if not card_placed:
		for card in hand.player_hand:
			hand.remove_card_from_hand(card)
			var correct_slot = ai_slot.get_node("QUARTZ")
			card_placed = game_actions.try_place_card(card, correct_slot)
			if card_placed:
				break
			 
	if not card_placed:
		print("IA não conseguiu jogar nenhuma carta, nem no slot QUARTZ")
			
			
	

## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
	
	
func decide_best_action():
	var best_score = -1000000 # Um valor muito baixo para garantir que qualquer jogada válida seja melhor
	var best_action = null    # Armazenará a melhor ação (e.g., {"type": "play_card", "card": card, "slot": slot})
	
	# --- 1. Avaliar todas as jogadas de cartas possíveis ---
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
					
	# --- 2. Avaliar a ação de Descartar e Comprar ---
	var discard_cost = {"large": 0, "small": 2}
	if can_use_mana(discard_cost.large, discard_cost.small):
		# Descartar e comprar é uma boa opção se não houver jogadas boas e a mão for ruim.
		# Por simplicidade inicial, podemos dar um "score" fixo ou baseado na mão atual.
		var discard_score = evaluate_discard_and_draw()
		if discard_score > best_score: # Se for melhor que a melhor jogada de carta
			best_score = discard_score
			best_action = {"type": "discard_and_draw", "cost": discard_cost}
			
	# --- 3. Avaliar a ação de Passar a Vez e Comprar (se não jogar nada) ---
	# Se a IA não tiver mana ou boas jogadas, passar a vez para comprar pode ser a única opção
	# Não tem custo de mana, mas o ganho é indireto (futuras cartas melhores).
	# Este é geralmente o último recurso se nenhuma outra ação for boa.
	# Por agora, vamos assumir que se não há 'best_action', ela passa a vez.
	
	 # --- Executar a Melhor Ação ---
	if best_action:
		print(str("IA decidiu: ", best_action.type, " com score: ", best_score))
		execute_action(best_action)
	else:
		print("IA não encontrou nenhuma ação ideal. Passando a vez para comprar uma carta.")
		# Se não há best_action, significa que nenhuma jogada é possível ou boa.
		# Automaticamente passa a vez para comprar (ou simplesmente passa)
		# Você pode ter uma função específica aqui para 'passar a vez e comprar'
		# Por enquanto, apenas avança para o fim do turno.
		pass # A ação de passar o turno e comprar pode ser feita implicitamente pelo GM

func get_potential_slots(card: Card) -> Array:
	var potential_slots = []
	var ai_slots_nodes = ai_slot.get_children() # Assumindo que ai_slot.get_children() são os slots do campo da IA
	var can_play
	for slot_node in ai_slots_nodes:
		can_play = game_actions.can_place_card(card, slot_node, true)[0] #passando que é IA 
		if can_play:
			potential_slots.append(slot_node)
	return potential_slots
	
func calculate_play_cost(card: Card, target_slot: Node) -> Dictionary:
	var can_place_card = game_actions.can_place_card(card, target_slot, true)
	var cost_big = can_place_card[1]
	var cost_small = can_place_card[2]
	var cost = {"large": cost_big, "small": cost_small}
	return cost
	
func evaluate_play_card(card: Card, target_slot: Node, cost: Dictionary) -> float:
	var score = 0.0
	# Adiciona o rank da carta (LOW/MID/HIGH) ou 1 (ACE)
	if card.type == "ACE":
		score += 1.0
	else:
		score += float(card.rank)
	# Penaliza pelo custo de mana (quanto mais mana, menos pontuação base)
	score -= (cost.large * 5.0) # Mana grande penaliza mais
	score -= (cost.small * 1.0) # Mana pequena penaliza menos

	# --- Lógica para simular o estado do slot e dar bônus ---
	# Isso é o mais complexo e onde você vai precisar simular o 'try_place_card'
	# de forma a saber o novo total de pontos ou se a combinação é fechada.
	# Exemplo simplificado:
	var current_slot_value = 0 # Você precisaria de um jeito de saber o valor atual do slot
	for existing_card_in_slot: Card in target_slot.get_children():
		if existing_card_in_slot.type == "ACE": current_slot_value += 1
		else: current_slot_value += existing_card_in_slot.rank

	var projected_slot_value = current_slot_value + (1 if card.type == "ACE" else card.rank)

	if projected_slot_value == 15:
		score += 100.0 # ENORME BÔNUS por fechar um slot com 15 pontos!
		print("IA avaliando: Jogada fecha slot com 15 pontos!")
	elif projected_slot_value > 15:
		score -= 50.0 # GRANDE PENALIDADE se a jogada ultrapassar 15 pontos e invalidar

	# Bônus por jogar em QUARTZ se for uma boa pontuação (e a carta não for ACE)
	if target_slot.name.to_upper() == "QUARTZ" and card.type != "ACE" and projected_slot_value <= 15:
		score += 5.0 # Prioriza QUARTZ se a combinação for boa

	# Bônus por esvaziar a mão (se for a última carta)
	if hand.player_hand.size() == 1: # Se essa for a última carta
		score += 10.0
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
	
	var score = 0.0
	if hand.player_hand.size() > 0:
		# Penaliza por descartar uma carta, mas ganha pela chance de algo novo.
		# Poderia ser algo como: (Valor_Esperado_Nova_Carta) - (Valor_Pior_Carta_Na_Mao) - Custo
		
		# Por simplicidade, vamos dar um score base.
		score = 3.0 # Um valor que pode ser competitivo com jogadas de carta não ótimas

		# Se a mão da IA está cheia de cartas que não podem ser jogadas, este score sobe.
		var unplayable_cards = 0
		for card in hand.player_hand:
			if get_potential_slots(card).is_empty():
				unplayable_cards += 1
		if unplayable_cards == hand.player_hand.size(): # Todas as cartas são injogáveis
			score += 15.0 # Grande bônus se a IA está travada!
			
	return score
	
func execute_action(action: Dictionary):
	# Consome a mana da IA
	big_mana_AI -= action.cost.large
	small_mana_AI -= action.cost.small
	print(str("Mana restante: G", big_mana_AI, " P", small_mana_AI))

	if action.type == "play_card":
		var card_to_play: Card = action.card
		var target_slot: Node = action.slot
		
		hand.remove_card_from_hand(card_to_play) # Remove do array da mão
		
		# Esta é a chamada real para jogar a carta no jogo
		# Certifique-se de que game_actions.try_place_card move o nó da carta!
		var success = game_actions.try_place_card(card_to_play, target_slot)
		if not success:
			print("ERRO CRÍTICO: IA tentou jogar carta, mas try_place_card falhou! ", card_to_play.name, " em ", target_slot.name)
			# Você pode querer adicionar a carta de volta à mão ou descartá-la aqui
			
	elif action.type == "discard_and_draw":
		print("IA decidiu descartar uma carta e comprar outra.")
		# Lógica para descartar uma carta (talvez a de menor valor ou a mais injogável)
		# E depois puxar uma nova carta do deck
		
		# Para fins de demonstração, descarta a primeira carta:
		if hand.player_hand.size() > 0:
			var card_to_discard: Card = hand.player_hand[0] # Ou escolha a pior carta
			hand.remove_card_from_hand(card_to_discard)
			print(str("IA descartou: ", card_to_discard.name))
			# Mova card_to_discard para sua pilha de descarte
			# get_node("/root/match/DiscardPile").add_child(card_to_discard)
			
			# Puxa uma nova carta (assumindo GameManager tem essa função)
			var deck_global = GM.get_node("DeckGlobal") # Ajuste o caminho
			var new_card = GM.puxar_carta_do_deck_para_mao(hand.player_hand, deck_global) # Passar o array para adicionar
			if new_card:
				print(str("IA comprou uma nova carta: ", new_card.name))
		else:
			print("IA tentou descartar, mas não tinha cartas.")
