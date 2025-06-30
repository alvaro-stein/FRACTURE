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
@onready var your_turn: RichTextLabel = $YourTurn



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


func _on_end_turn():
	#ação de passar o turno e comprar mais uma carta
	if self.current_player.has_full_mana():
		if deck.deck_pile:
			game_actions.buy_card()
	
	if self.current_player == player:
		clock.disabled = true
		self.current_player = AI
	else:
		self.current_player = player
		your_turn_warning()
		clock.disabled = false
	
	current_player.reset_mana()
	
	if deck.deck_pile:
		game_actions.buy_card()
	else: # este é o último turno do jogo
		clock.last_turn = true
	
	if self.current_player != player:
		emit_signal("ai_turn_started")
		
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

func your_turn_warning():
	var tween = self.create_tween()
	tween.tween_property(your_turn, "modulate:a", 1, 0.25)
	await get_tree().create_timer(1.5).timeout
	var tween1 = self.create_tween()
	tween1.tween_property(your_turn, "modulate:a", 0, 0.25)
