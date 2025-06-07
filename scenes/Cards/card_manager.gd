extends Node2D

#const COLLISION_MASK_CARD = 1   # Unused for now
var standard_z_index = self.z_index
var screen_size: Vector2
var mouse_pos: Vector2
var card_being_dragged: Node2D = null
var highlighted_card: Node2D = null
var last_card_hovered: Node2D = null
var card_slot_hovered: Node2D = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if card_being_dragged:
		mouse_pos = get_global_mouse_position()
		mouse_pos.x = clamp(mouse_pos.x, 0, screen_size.x)
		mouse_pos.y = clamp(mouse_pos.y, 0, screen_size.y)
		card_being_dragged.position = mouse_pos


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and highlighted_card:
		start_drag() if event.pressed else finish_drag()
		# Código antigo colapsado - são da versão do Barry
		#card_being_dragged = raycast_check_for_card() if event.pressed else null
		##if event.pressed:
			###var card: Node2D = raycast_check_for_card()
			###if card:
				###card_being_dragged = card
			##card_being_dragged = raycast_check_for_card()
		##else:
			##card_being_dragged = null


func start_drag() -> void:
	card_being_dragged = highlighted_card
	highlighted_card.scale = Vector2(1, 1)


func finish_drag() -> void:
	highlighted_card.scale = Vector2(1.1, 1.1)
	if card_slot_hovered and card_being_dragged and card_slot_hovered.is_empty:
		# Then drop the card into the empty card slot
		card_slot_hovered.is_empty = false
		card_being_dragged.position = card_slot_hovered.position
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
	card_being_dragged = null


# Código raycast colapsado - toda a função é da versão do Barry
#func raycast_check_for_card() -> Node2D:
	#var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	#var parameters := PhysicsPointQueryParameters2D.new()
	#parameters.position = get_global_mouse_position()
	#parameters.collide_with_areas = true
	#parameters.collision_mask = COLLISION_MASK_CARD
	#var result = space_state.intersect_point(parameters)
	#if result:
		#return result[0].collider.get_parent()
	#return null


# Card implementation
func connect_card_signals(card: Node2D) -> void:
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)


func on_hovered_over_card(card: Node2D) -> void:
	last_card_hovered = card
	if not highlighted_card:
		highlighted_card = card
		highlight_card(card, true)


func on_hovered_off_card(card: Node2D) -> void:
	if highlighted_card == card:
		highlighted_card = null
		highlight_card(card, false)
		if last_card_hovered != card:
			highlighted_card = last_card_hovered
			highlight_card(last_card_hovered, true)
		else:
			last_card_hovered = null
	else:
		last_card_hovered = highlighted_card


func highlight_card(card: Node2D, hovered: bool) -> void:
	if hovered:
		card.scale = Vector2(1.1, 1.1)
		card.z_index = standard_z_index + 1
	else:
		card.scale = Vector2(1, 1)
		card.z_index = standard_z_index


# Card slot implementation
func connect_card_slot_signals(card_slot: Node2D) -> void:
	card_slot.connect("hovered", on_hovered_over_card_slot)
	card_slot.connect("hovered_off", on_hovered_off_card_slot)


# Does not handle overlapping card slots (probably not needed)
func on_hovered_over_card_slot(card_slot: Node2D) -> void:
	card_slot_hovered = card_slot


func on_hovered_off_card_slot(card_slot: Node2D) -> void:
	card_slot_hovered = null
