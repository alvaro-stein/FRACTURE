class_name Card extends Node2D

signal hovered
signal hovered_off

const COLOR: Array[String] = ["GOLD", "SAPPHIRE", "RUBY", "EMERALD"]
const TYPE: Array[String] = ["ACE", "LOW", "MID", "HIGH"]

@onready var game_actions = $"../../GameActions"
const CARD_SCENE = preload("res://scenes/cards/card.tscn")
var is_facing_down = true
var is_selected = false
var color: String
var type: String
var rank: int


func card_set_z_index(index: int) -> void:
	self.z_index = index
	self.get_node("Front").z_index = index
	self.get_node("Back").z_index = index


func flip(play_sound: bool) -> void:
	if play_sound: AudioGlobal.card_flip.play()
	if is_facing_down:
		$"AnimationPlayer".play("flip")
		is_facing_down = false
	else:
		$"AnimationPlayer".play_backwards("flip")
		is_facing_down = true


static func new_card(color: String, rank: int) -> Card:
	var new_card = CARD_SCENE.instantiate()
	new_card.rank = rank
	new_card.name = color + str(rank)
	new_card.color = color
	if rank == 1:
		new_card.type = TYPE[0]
	elif rank <= 4:
		new_card.type = TYPE[1]
	elif rank <= 7:
		new_card.type = TYPE[2]
	elif rank <= 10:
		new_card.type = TYPE[3]
	new_card.get_node("Front").texture = load("res://assets/sprites/NewCards/%s%s_DEFAULT.png" %[color, rank])
	return new_card	


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# All Cards must be a child of CardManager or this will error
	get_parent().connect_card_signals(self)


func _on_area_2d_mouse_entered() -> void:
	if self.get_parent().get_parent().name == "Match" and not game_actions.card_held:
		GameSettings.set_cursor("open")
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	if self.get_parent().get_parent().name == "Match" and not game_actions.card_held:
		GameSettings.set_cursor("default")
	emit_signal("hovered_off", self)
