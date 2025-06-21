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

func try_use_mana(big_mana: int, small_mana: int):
	if self.big_mana_AI >= big_mana and self.small_mana_AI >= small_mana:
		self.big_mana_AI -= big_mana
		self.small_mana_AI -= small_mana
		self.update_mana_visual(small_mana_AI, big_mana_AI)
		return true
	else: 
		if big_mana == 0 and self.big_mana_AI and self.small_mana_AI < small_mana:
			if self.small_mana_AI + 1 >= small_mana: #troca uma mana grande por uma pequena
				self.small_mana_AI += 1
				self.big_mana_AI = 0
				self.small_mana_AI -= small_mana
				self.update_mana_visual(small_mana_AI, big_mana_AI)
				return true
		return false

func _start_ai_turn():
	print("AI começa o turno")
	await get_tree().create_timer(1).timeout #pensando
	var first_card : Card = self.hand.player_hand[0]
	var ai_slots = self.ai_slot.get_children()
	hand.remove_card_from_hand(first_card)
	game_actions.try_place_card(first_card, ai_slots[3])
			
	GM._on_end_turn() #gambiarra só pra AI terminar o turno


## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
