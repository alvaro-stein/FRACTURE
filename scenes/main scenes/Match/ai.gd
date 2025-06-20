extends MatchPlayer
class_name AI

@onready var mana_p_1: Sprite2D = $ManaP1
@onready var mana_p_2: Sprite2D = $ManaP2
@onready var mana_g: Sprite2D = $ManaG

var big_mana_AI := 1
var small_mana_AI := 2

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

## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
