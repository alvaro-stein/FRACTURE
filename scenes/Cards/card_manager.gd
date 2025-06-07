extends Node2D

#const COLLISION_MASK_CARD = 1
var screen_size: Vector2
var mouse_pos: Vector2
var card_being_dragged: Node2D = null
var highlighted_card: Node2D = null
var last_entered: Node2D = null


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
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#card_being_dragged = highlighted_card if event.pressed else null
		if event.pressed:
			card_being_dragged = highlighted_card
			highlighted_card.scale = Vector2(1, 1)
		else:
			highlighted_card.scale = Vector2(1.1, 1.1)
			card_being_dragged = null
		#card_being_dragged = raycast_check_for_card() if event.pressed else null
		##if event.pressed:
			###var card: Node2D = raycast_check_for_card()
			###if card:
				###card_being_dragged = card
			##card_being_dragged = raycast_check_for_card()
		##else:
			##card_being_dragged = null
# Todos os códigos comentados acima são da versão do Barry

# Toda essa função cometada abaixo é da versão do Barry
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


func connect_card_signals(card: Node2D):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)


func on_hovered_over_card(card: Node2D) -> void:
	last_entered = card
	if not highlighted_card:
		highlighted_card = card
		highlight_card(card, true)


func on_hovered_off_card(card: Node2D) -> void:
	if highlighted_card == card:
		highlighted_card = null
		highlight_card(card, false)
		if last_entered != card:
			highlighted_card = last_entered
			highlight_card(last_entered, true)
		else:
			last_entered = null
	else:
		last_entered = highlighted_card


func highlight_card(card: Node2D, hovered: bool):
	if hovered:
		card.scale = Vector2(1.1, 1.1)
		card.z_index = 2
	else:
		card.scale = Vector2(1, 1)
		card.z_index = 1
