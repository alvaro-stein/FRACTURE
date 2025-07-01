extends Node2D
class_name TutorialForge2

signal change_scene_to

const CARD_LAYER := 2 # Layer 2, valor 2
const SLOT_LAYER := 4 # Layer 3, valor 4 # Pois são potencias de 2
const DISCARD_PILE_LAYER := 8 # Layer 4, valor 8
@onready var player_hand: Node2D =$PlayerHandForge2
@onready var card_manager: Node2D = $CardManager
@onready var continue_button: Button = $ContinueButton
#@onready var score: Node = $Score
#@onready var card_slot_manager: Node2D = $CardSlotManager
@onready var text_box: RicherTextLabel = $TextBox
@onready var text_box_2: RicherTextLabel = $TextBox2

var card_held: Card = null
var mouse_pos: Vector2
var screen_size: Vector2
var cards_forged: int = 0 

func _ready() -> void:
	get_parent().connect_change_scene_signals(self)
	var color = ["RUBY", "RUBY", "SAPPHIRE"]
	var rank = [7, 5, 2]
	var i = 0
	for card in card_manager.get_children():
		card.get_node("Front").texture = load("res://assets/sprites/NewCards/%s%s_DEFAULT.png" %[color[i], rank[i]])
		card.flip(true)
		i += 1
		
	#self.hide_slots()
	text_box_2.visible = false
	continue_button.disabled = true
	screen_size = get_viewport_rect().size

	player_hand.valid_forge2.connect(valid_forge2)
	player_hand.invalid_forge2.connect(invalid_forge2)
	player_hand.end_forge2.connect(finish_tutorial)
	
	var new_card: Card = Card.new_card("RUBY", 2)
	new_card.position = Vector2(-50, 540)
	card_manager.add_child(new_card)
	new_card.flip(true)
	new_card.get_node("Area2D/CollisionShape2D").disabled = false
	player_hand.add_card_to_hand(new_card)
	
	new_card = Card.new_card("SAPPHIRE", 2)
	new_card.position = Vector2(-50, 540)
	card_manager.add_child(new_card)
	new_card.flip(true)
	new_card.get_node("Area2D/CollisionShape2D").disabled = false
	player_hand.add_card_to_hand(new_card)
	
	new_card = Card.new_card("GOLD", 2)
	new_card.position = Vector2(-50, 540)
	card_manager.add_child(new_card)
	new_card.flip(true)
	new_card.get_node("Area2D/CollisionShape2D").disabled = false
	player_hand.add_card_to_hand(new_card)
	
	new_card = Card.new_card("EMERALD", 8)
	new_card.position = Vector2(-50, 540)
	card_manager.add_child(new_card)
	new_card.flip(true)
	new_card.get_node("Area2D/CollisionShape2D").disabled = false
	player_hand.add_card_to_hand(new_card)


func _on_continue_button_button_up() -> void:
	AudioGlobal.button.play()
	emit_signal("change_scene_to", "TutorialEndTurn")

func _on_return_button_button_up() -> void:
	AudioGlobal.button.play()
	emit_signal("change_scene_to", "TutorialCostMana")
	
func invalid_forge2():
	text_box_2.text = "Essas cartas não podem ser forjadas, tente novamente. Lembre-se das combinações possíveis entre 2, 5 e 8."
	await get_tree().process_frame
	text_box_2.custom_minimum_size = Vector2(0, 0)
	var content_height = text_box_2.get_content_height()
	var content_width = text_box_2.get_content_width()
	text_box_2.size = Vector2(content_width, content_height)
	
func valid_forge2():
	text_box_2.text = "Bem jogado! Você forjou sua primeira carta! Forje mais uma para continuar."
	await get_tree().process_frame
	text_box_2.custom_minimum_size = Vector2(0, 0)
	var content_height = text_box_2.get_content_height()
	var content_width = text_box_2.get_content_width()
	text_box_2.size = Vector2(content_width, content_height)

func finish_tutorial():
	text_box_2.text = "É isso! Você aprendeu as diferentes formas de forjar cartas e agora pode fazer jogadas ainda melhores!"
	await get_tree().process_frame
	text_box_2.custom_minimum_size = Vector2(0, 0)
	var content_height = text_box_2.get_content_height()
	var content_width = text_box_2.get_content_width()
	text_box_2.size = Vector2(content_width, content_height)
	continue_button.disabled = false
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			card_held = try_get_card()
			if card_held:
				self.start_drag()
		else:
			finish_drag()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var highlighted_card = try_get_card()
		if highlighted_card:
			player_hand._on_card_right_clicked(highlighted_card)

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

func start_drag() -> void:
	player_hand.remove_card_from_hand(card_held)
	card_held.scale = Vector2(1, 1)
	
func try_get_slot() -> CardSlot:
	var result = raycast_at_cursor(SLOT_LAYER)
	return result[0].collider.get_parent() if result else null


func finish_drag() -> void:
	if card_held:
		card_held.scale = Vector2(1.05, 1.05)
		#var card_slot_hovered = try_get_slot()
		#if card_slot_hovered and self.can_place_card(card_held, card_slot_hovered, 0):
			#card_slot_hovered.add_card_to_slot(card_held, 0)
			#score_uptade(card_held.rank, card_slot_hovered.color)
		
		#substituido para, pois o jogador não poderá jogar cartas
		player_hand.add_card_to_hand(card_held)
		card_held = null

#func hide_slots():
	#for slot in card_slot_manager.get_node("AISlot").get_children():
		#slot.visible = false
		
#func can_place_card(card: Card, slot: CardSlot, is_AI: bool):
	#var can_place: bool
	#
	#var allowed_slot: bool
	#if is_AI:
		#allowed_slot = slot.get_parent().name == "AISlot"
	#else:
		#allowed_slot = slot.get_parent().name == "PlayerSlot"
	#
	## Regras de combinação por tipo
	#var combination = true
	#
	## Condições para jogar a carta
	#var rules := [
		#card.color == slot.color or slot.color == "QUARTZ",
		##card in GM.current_player.hand.player_hand,
		#combination,
		#allowed_slot
	#]
	#var can_play = rules.reduce(func(a, b): return a and b)
	#return can_play
	#
#func score_uptade(value, color):
	#score.get_node(color.to_upper()).get_node("SpinScore").play("spin score")
	#var score_label: Label = score.get_node(color.to_upper())
	#score_label.text = str(int(score_label.text) + value)
	#if int(score_label.text) == 0:
		#score_label.set("theme_override_colors/font_color", Color.BLACK)
	#elif int(score_label.text) < 0:
		#score_label.set("theme_override_colors/font_color", Color.FIREBRICK)
	#else:
		#score_label.set("theme_override_colors/font_color", Color.SEA_GREEN)


func _on_text_box_anim_finished() -> void:
	text_box_2.progress = 0.0
	await get_tree().create_timer(0.5).timeout
	text_box_2.visible = true
