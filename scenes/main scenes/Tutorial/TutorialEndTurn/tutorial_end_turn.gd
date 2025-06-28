extends Node2D
class_name TutorialEndTurn

signal change_scene_to

const CARD_LAYER := 2 # Layer 2, valor 2
const SLOT_LAYER := 4 # Layer 3, valor 4 # Pois são potencias de 2
const DISCARD_PILE_LAYER := 8 # Layer 4, valor 8
const ARROW_SCENE = preload("res://scenes/Secundary Scenes/pointing_arrow.tscn")

var card_held: Card = null
var mouse_pos: Vector2
var screen_size: Vector2
var arrow

@onready var card_slot_manager: Node2D = $CardSlotManager
@onready var card_manager: Node2D = $CardManager
@onready var clock: Button = $Clock
@onready var text_box: RicherTextLabel = $TextBox
@onready var text_box_2: RicherTextLabel = $TextBox2
@onready var player_hand_end_turn: PlayerHandForge2 = $PlayerHandEndTurn
@onready var continue_button: Button = $ContinueButton

func _on_continue_button_button_up() -> void:
	AudioGlobal.button.play()
	emit_signal("change_scene_to", "TutorialEndGame")

func _on_return_button_button_up() -> void:
	AudioGlobal.button.play()
	emit_signal("change_scene_to", "TutorialForge2")

func _ready() -> void:
	get_parent().connect_change_scene_signals(self)
	text_box_2.visible = false 
	clock._end_turn.connect(clock_clicked)
	clock.reset_timer()
	continue_button.disabled = true
	screen_size = get_viewport_rect().size
	arrow = ARROW_SCENE.instantiate()
	self.add_child(arrow)
	arrow.point_at(Vector2(1691.5, 544), Vector2(-40, -0))
	arrow.z_index = 1
	
	
	
func clock_clicked():
	clock.stop_timer()
	clock.disabled = true
	text_box_2.visible = true 
	text_box.visible = false
	continue_button.disabled = false
	
	arrow.hide_arrow()
	arrow.point_at(Vector2(1735, 825.0), Vector2(-40, -0))
	arrow.show_arrow()
	
	var new_card: Card = Card.new_card("EMERALD", 6)
	new_card.position = Vector2(-50, 540)
	card_manager.add_child(new_card)
	new_card.flip(true)
	new_card.get_node("Area2D/CollisionShape2D").disabled = false
	player_hand_end_turn.add_card_to_hand(new_card)


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

func try_get_discard_pile() -> DiscardPile:
	var result = raycast_at_cursor(DISCARD_PILE_LAYER)
	return result[0].collider.get_parent() if result else null

func start_drag() -> void:
	player_hand_end_turn.remove_card_from_hand(card_held)
	card_held.scale = Vector2(1, 1)

func finish_drag() -> void:
	if card_held:
		card_held.scale = Vector2(1.05, 1.05)
		player_hand_end_turn.add_card_to_hand(card_held)
		card_held = null
