extends Node2D
@onready var deck_types: Node2D = $DeckTypes

const TRUE_CARD_WIDTH: float = 148.0
const TRUE_CARD_HEIGHT: float = 200.0

const HORIZONTAL_SPACING: float = 10.0 # Espaço horizontal entre colunas
const VERTICAL_SPACING: float = 15.0  # Espaço vertical entre linhas
const START_POSITION: Vector2 = Vector2(249, 140)
const CARDS_PER_ROW: int = 10
const DECK_POSITION: Vector2 = Vector2(-213.0, 540)
const DURATION_PER_CARD: float = 0.5 
const DELAY_BETWEEN_CARDS: float = 0.1

func _on_continue_button_button_up() -> void:
	pass # Replace with function body.


func _on_return_button_button_up() -> void:
	pass # Replace with function body.

func _ready() -> void:
	deck_types.deck_ready.connect(distribute_cards)

func distribute_cards():
	if deck_types.deck_pile.is_empty():
		return
		
	var column_x_positions := [400, 773, 1146, 1520]

	for i in range(deck_types.deck_pile.size()):
		var card = deck_types.deck_pile[i]
		card.position = DECK_POSITION

		var column := i / 3  # 3 cartas por coluna
		var row := i % 3     # até 3 linhas por coluna

		var target_x = column_x_positions[column]
		var target_y = START_POSITION.y + row * (TRUE_CARD_HEIGHT + VERTICAL_SPACING)
		var target_position := Vector2(target_x, target_y)

		var tween = create_tween()
		tween.tween_property(card, "position", target_position, 0.5)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		
		tween.tween_property(card, "position", target_position, DURATION_PER_CARD)
		
		await get_tree().create_timer(DELAY_BETWEEN_CARDS).timeout
		
		card.flip()
		
			
	print("Distribuição de cartas concluída.")
