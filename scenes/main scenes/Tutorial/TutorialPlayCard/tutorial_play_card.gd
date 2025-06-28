extends Node2D
class_name TutorialPlay

signal change_scene_to

const CARD_LAYER := 2 # Layer 2, valor 2
const SLOT_LAYER := 4 # Layer 3, valor 4 # Pois são potencias de 2
const DISCARD_PILE_LAYER := 8 # Layer 4, valor 8
const ARROW_SCENE = preload("res://scenes/Secundary Scenes/pointing_arrow.tscn")
@onready var player_hand: PlayerHand = $PlayerHand
@onready var card_manager: Node2D = $CardManager
@onready var continue_button: Button = $ContinueButton
@onready var score: Node = $Score
@onready var card_slot_manager: Node2D = $CardSlotManager
@onready var text_box: RicherTextLabel = $TextBox

var card_held: Card = null
var mouse_pos: Vector2
var screen_size: Vector2

func _ready() -> void:
	get_parent().connect_change_scene_signals(self)
	continue_button.disabled = true
	screen_size = get_viewport_rect().size
	
	var new_card_enemy: Card = Card.new_card("GOLD", 9)
	card_manager.add_child(new_card_enemy)
	new_card_enemy.position = Vector2(960.0, 0)
	card_slot_manager.get_node("AISlot").get_node(new_card_enemy.color.to_upper()).add_card_to_slot(new_card_enemy, true)
	score_uptade(-new_card_enemy.rank, new_card_enemy.color)
	
	await get_tree().create_timer(0.5, false).timeout
	
	var new_card: Card = Card.new_card("GOLD", 10)
	new_card.position = Vector2(-50, 540)
	card_manager.add_child(new_card)
	new_card.flip(true)
	new_card.get_node("Area2D/CollisionShape2D").disabled = false
	player_hand.add_card_to_hand(new_card)
	
func _on_continue_button_button_up() -> void:
	AudioGlobal.button.play()
	emit_signal("change_scene_to", "TutorialHowToWin")

func _on_return_button_button_up() -> void:
	AudioGlobal.button.play()
	emit_signal("change_scene_to", "TutorialSlot")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			card_held = try_get_card()
			if card_held:
				self.start_drag()
		else:
			finish_drag()

func _process(delta: float) -> void:
	self.drag_card()

func drag_card() -> void:
	if card_held:
		mouse_pos = get_global_mouse_position()
		mouse_pos.x = clamp(mouse_pos.x, 0, screen_size.x)
		mouse_pos.y = clamp(mouse_pos.y, 0, screen_size.y)
		card_held.position = mouse_pos

func raycast_at_cursor(collision_mask: int) -> Array[Dictionary]:
	# Get the 2D physics space state from the current world.
	var space_state = get_world_2d().direct_space_state
	mouse_pos = get_global_mouse_position()
	# Create the query parameters object.
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collision_mask = collision_mask
	query.collide_with_areas = true
	# Returns an Array[Dictionary]
	return space_state.intersect_point(query)


func try_get_card() -> Card:
	var results: Array[Dictionary] = raycast_at_cursor(CARD_LAYER)
	var cards: Array = []
	for i in results.size():
		cards.append(results[i].collider.get_parent())
	if cards:
		var card_under_cursor = cards[0]
		for card in cards:
			if card.z_index > card_under_cursor.z_index:
				card_under_cursor = card
		return card_under_cursor
	else:
		return null

func try_get_slot() -> CardSlot:
	var result = raycast_at_cursor(SLOT_LAYER)
	return result[0].collider.get_parent() if result else null

func start_drag() -> void:
	player_hand.remove_card_from_hand(card_held)
	card_held.scale = Vector2(1, 1)

func finish_drag() -> void:
	if card_held:
		card_held.scale = Vector2(1.05, 1.05)
		var card_slot_hovered = try_get_slot()
		if card_slot_hovered and self.can_place_card(card_held, card_slot_hovered, 0):
			card_slot_hovered.add_card_to_slot(card_held, 0)
			score_uptade(10, card_slot_hovered.color)
			finish_tutorial()
		else: # Return card to hand
			player_hand.add_card_to_hand(card_held)
		card_held = null

func can_place_card(card: Card, slot: CardSlot, is_AI: bool):
	var can_place: bool
	
	var allowed_slot: bool
	if is_AI:
		allowed_slot = slot.get_parent().name == "AISlot"
	else:
		allowed_slot = slot.get_parent().name == "PlayerSlot"
	
	# Regras de combinação por tipo
	var combination = true
	
	# Condições para jogar a carta
	var rules := [
		card.color == slot.color,
		#card in GM.current_player.hand.player_hand,
		combination,
		allowed_slot
	]
	var can_play = rules.reduce(func(a, b): return a and b)
	return can_play
	
func score_uptade(value, color):
	score.get_node(color.to_upper()).get_node("SpinScore").play("spin score")
	var score_label: Label = score.get_node(color.to_upper())
	score_label.text = str(int(score_label.text) + value)
	if int(score_label.text) == 0:
		score_label.set("theme_override_colors/font_color", Color.BLACK)
	elif int(score_label.text) < 0:
		score_label.set("theme_override_colors/font_color", Color.FIREBRICK)
	else:
		score_label.set("theme_override_colors/font_color", Color.SEA_GREEN)

func finish_tutorial():
	text_box.text = "[fill]Boa! Você somou pontos ao jogar a carta! É assim que você irá ganhar do seu oponente. [/fill]"
	var arrow = ARROW_SCENE.instantiate()
	self.add_child(arrow)
	arrow.point_at(Vector2(440.0, 540.0), Vector2(-40, -40))
	await get_tree().create_timer(0.5, false).timeout
	continue_button.disabled = false
