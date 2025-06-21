extends MatchPlayer
class_name Player


signal set_time()
signal use_time()


var big_mana_player := 1
var small_mana_player := 2
var hand : PlayerHand
var time_left : float
var time_pass : int
var timer_set : bool = false
#var gm: GameManager

@onready var mana_p_1: Sprite2D = $ManaP1
@onready var mana_p_2: Sprite2D = $ManaP2
@onready var mana_g: Sprite2D = $ManaG

const MANA_GRANDE = preload("res://assets/mana/Mana Grande.png")
const MANA_PEQUENA = preload("res://assets/mana/Mana Pequena.png")

func _ready() -> void:
	self.mana_texture()
	self.mana_scale()
	self.mana_position()
	
func mana_texture():
	mana_p_1.texture = MANA_PEQUENA
	mana_p_2.texture = MANA_PEQUENA
	mana_g.texture = MANA_GRANDE
	
func mana_scale():
	mana_p_1.scale = Vector2(0.12, 0.12)
	mana_p_2.scale = Vector2(0.12, 0.12)
	mana_g.scale = Vector2(0.13, 0.13)

func mana_position():
	mana_p_1.position =  Vector2(800, -100)
	mana_p_2.position = Vector2(800, -215)
	mana_g.position = Vector2(810, -360)
	
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
	self.big_mana_player = 1
	self.small_mana_player  = 2
	self.update_mana_visual(small_mana_player, big_mana_player)
	
	
#func _init(nickname: String, id:int, hand: Node) -> void:
	#self.nickname = nickname
	#self.id = id
	#self.hand = hand
	#self.big_mana_player = 1
	#self.small_mana_player = 2
	#self.time_pass = 7200
	#self.time_left = 0

#static func create_from_player(player: Player, hand: Node):
	#return MatchPlayer.new(player.nickname, player.id, hand)

func try_use_mana(big_mana: int, small_mana: int):
	if self.big_mana_player >= big_mana and self.small_mana_player >= small_mana:
		self.big_mana_player -= big_mana
		self.small_mana_player -= small_mana
		self.update_mana_visual(small_mana_player, big_mana_player)
		return true
	else: #aprimorar essa parte?
		if big_mana == 0 and self.big_mana_player and self.small_mana_player < small_mana:
			if self.small_mana_player + 1 >= small_mana: #troca uma mana grande por uma pequena
				self.small_mana_player += 1
				self.big_mana_player = 0
				self.small_mana_player -= small_mana
				self.update_mana_visual(small_mana_player, big_mana_player)
				return true
		return false


#func set_game_manager(game_manager: GameManager):
	#self.gm = game_manager

func buy_card(buy_deck):
	var new_card = buy_deck.card_slot.cards[0]
	if new_card:
		self.hand.card_slot.add_card(new_card)
		#if self == gm.get_local_player():
			#self.hand.card_face_up(new_card)
		print(self.nickname + " comprou a carta " + new_card.name)
		return true
	else:
		print("Erro: sem cartas no baralho!")
		return false



func set_timer():
	set_time.emit()
	if timer_set == false:
		timer_set = true


func try_buy_card(buy_deck: Node, condicao: bool = false):
	if condicao:
		buy_card(buy_deck)
		return
	#GameEvents.on_buy_button_pressed.emit(self.buy_card.bind(buy_deck))



#func try_end_turn():
	#GameEvents.on_end_turn_button_pressed.emit(self.end_turn.bind())
#
#func end_turn():
	#gm.end_turn()
	#
