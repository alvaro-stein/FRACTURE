class_name Card extends Node2D

signal hovered
signal hovered_off


const CARD_SCENE = preload("res://scenes/cards/card.tscn")
var is_facing_down = true


func flip() -> void:
	if is_facing_down:
		$"AnimationPlayer".play("flip")
		is_facing_down = false
	else:
		$"AnimationPlayer".play_backwards("flip")
		is_facing_down = true


static func new_card(suit: String, rank: int) -> Card:
	var new_card = CARD_SCENE.instantiate()
	new_card.get_node("Front").texture = load("res://assets/sprites/balatro cards/numbered/%s%s.png" %[suit, rank])
	return new_card


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# All Cards must be a child of CardManager or this will error
	get_parent().connect_card_signals(self)


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
