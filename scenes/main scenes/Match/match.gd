extends Node
class_name GameManager

signal change_scene_to
signal ai_turn_started

const INITIAL_HAND_SIZE := 5

@onready var clock: Button = $Clock
@onready var player: MatchPlayer = $"Player"
var player_hand:
	get: return player.get_node("PlayerHand")
@onready var AI: MatchPlayer = $"AI"
var AI_hand:
	get: return AI.get_node("PlayerHand")
@onready var game_actions: GameActions = $GameActions
@onready var deck: Deck = $Deck
@onready var score: Node = $Score
const FONT_COLOR_PATH := "theme_override_colors/font_color"


var game_started: bool = false
var current_player: MatchPlayer

var players : Array[MatchPlayer]
var turn : MatchPlayer

var buy_deck : Node
var discard_deck : Node
var somadores_por_coluna = [0, 0, 0, 0, 0]
var _hand
var _opposite_hand


func deal_initial_hand() -> void:
	var players = [AI, player]
	for i in INITIAL_HAND_SIZE:
		for each_player in players:
			await get_tree().create_timer(0.2, false).timeout
			self.current_player = each_player
			game_actions.buy_card()

func _ready() -> void:
	get_parent().connect_change_scene_signals(self)
	#await _init_players(self._hand, self._opposite_hand)
	clock._end_turn.connect(_on_end_turn)
	clock._end_game.connect(_on_end_game)
	game_actions.score_updated.connect(_on_score_updated)
	await get_tree().create_timer(1, false).timeout
	await self.deal_initial_hand()
	game_started = true
	clock.reset_timer()
	clock.disabled = false
	
	#self.turn = players[0]
	#GameEvents.on_game_over.connect(end_game)

func _notify_gm_is_ready():
	while self.players == []:
		await get_tree().create_timer(0.25, false).timeout
	if not self.is_node_ready():
		await self.ready
	#GameEvents.on_player_ready.emit()

#func _init_players(hand: Node, opposite_hand: Node):
	#self.players = []
	#var mp_players = await MultiplayerManager.client.get_players()
	#for mpp in mp_players:
		#var p: MatchPlayer
		#if mpp.id == multiplayer.get_unique_id():
			#p = MatchPlayer.create_from_player(mpp, hand)
			#print("You (%s) entered the match!" % mpp.id)
		#else:
			#p = MatchPlayer.create_from_player(mpp, opposite_hand)
			#print("%s entered the match!" % mpp.id)
		#self.players.append(p)
		#p.set_game_manager(self)
	#
	#if players.size() != 2:
		#push_error("Not enough players")

func create_cards(card_types_and_powers):
	for i in card_types_and_powers.size():
		#card.type_color = card_types_and_powers[i][0]
		#card.get_node("Power").text = str(card_types_and_powers[i][1])
		var card = Card.new_card(card_types_and_powers[i][0], card_types_and_powers[i][1]) 
		#coloquei os valores que estavam fora do new card para dentro do parentes, pois assim que está em FRACTURE2
		if str(card_types_and_powers[i][1]) == "G":
			card.type = "General"
		elif card_types_and_powers[i][1] in [2, 3, 4]:
			card.type = "Soldado"
			card.rank = "Baixo"
		elif card_types_and_powers[i][1] in [5, 6, 7]:
			card.type = "Soldado"
			card.rank = "Medio"
		elif card_types_and_powers[i][1] in [8, 9, 10]:
			card.type = "Soldado"
			card.rank = "Alto"
		self.buy_deck.get_parent().add_child(card)
		self.buy_deck.card_slot.add_card(card)
	
	var deal_cards = func():
		const CARD_QUANTITY_FOR_EACH_PLAYER = 5
		var alternate = false
		for i in CARD_QUANTITY_FOR_EACH_PLAYER * 2:
			var new_card = self.buy_deck.card_slot.cards[0]
			var receiving_player = self.players[0 if alternate else 1] 
			receiving_player.hand.card_slot.add_card(new_card)
			if receiving_player == self.get_local_player():
				receiving_player.hand.card_face_up(new_card)
			
			alternate = not alternate
			await get_tree().create_timer(0.2, false).timeout
	var timer = Timer.new()
	(timer.timeout as Signal).connect(deal_cards)
	timer.one_shot = true
	self.add_child(timer)
	timer.start(1.5)


# Alterna turnos
func end_turn(emit_event=true):
	self.turn = self.players[(self.players.find(self.turn) + 1) % 2]
	print("Turno do jogador: " + turn.nickname)
	self.turn.reset_mana() 
	self.turn.try_buy_card(self.buy_deck, true) #buy card automatic
	self.turn.reset_mana()
	#GameEvents.on_mana_reset.emit()
	self.turn.set_timer()
	#if emit_event:
		#MultiplayerManager.client.current_match.request_end_turn.rpc_id(1)

func _on_end_turn():
	#ação de passar o turno e comprar mais uma carta
	if self.current_player.has_full_mana():
		if deck.deck_pile:
			game_actions.buy_card()
	
	if self.current_player == player:
		clock.disabled = true
		self.current_player = AI
		emit_signal("ai_turn_started")
	else:
		self.current_player = player
		clock.disabled = false
	
	current_player.reset_mana()
	
	if deck.deck_pile:
		game_actions.buy_card()
	else: # este é o último turno do jogo
		clock.last_turn = true
	
	clock.reset_timer()


func _on_score_updated(score_change_value: int, color: String):
	score.get_node(color.to_upper()).get_node("SpinScore").play("spin score")
	var score_label: Label = score.get_node(color.to_upper())
	score_label.text = str(int(score_label.text) + score_change_value)
	if int(score_label.text) == 0:
		score_label.set(FONT_COLOR_PATH, Color.BLACK)
	elif int(score_label.text) < 0:
		score_label.set(FONT_COLOR_PATH, Color.FIREBRICK)
	else:
		score_label.set(FONT_COLOR_PATH, Color.SEA_GREEN)

func _on_end_game():
	clock.get_node("Timer").stop()
	self.add_child(load("res://scenes/main scenes/Match/end_scene.tscn").instantiate())

func who_win():
	var score_parent = get_node("Score")
	var player_slot_win = 0
	var AI_slot_win = 0
	var total_score = 0
	
	for score in score_parent.get_children():
		if int(score.text) > 0:
			player_slot_win += 1
			total_score += int(score.text)
		elif int(score.text) < 0:
			AI_slot_win += 1
			total_score += int(score.text)
			
	print(total_score)
	if player_slot_win > AI_slot_win:
		return "player"
	elif player_slot_win < AI_slot_win:
		return "AI"
	else: #iguais
		if total_score > 0:
			return "player"
		elif total_score < 0:
			return "AI"
		else:
			return "empate"






func return_card_to_player(card: Card):
	self.turn.hand.card_slot.position_cards()

func get_local_player():
	return self.players[0] if self.players[0].id == multiplayer.get_unique_id() else self.players[1]


func end_game():
	self.guardar_valores_somadores()
	print("Fim do jogo!")
	#GameData.player_scores = game_manager.get_player_scores() #pegar dados dos somadores
	get_tree().change_scene_to_file("res://Interface/Final/end_scene.tscn")

func guardar_valores_somadores():
	var valores = []
	for coluna in get_tree().get_nodes_in_group("colunas"):
		var somador = coluna.get_node("Somador")
		if somador:
			valores.append(int(somador.pontuacao_label.text))
		else:
			valores.append(0)
			
	#Valores.guardar_valores_somadores(valores)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
