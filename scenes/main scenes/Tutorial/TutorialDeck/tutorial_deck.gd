extends Node2D
class_name TutorialDeck

signal change_scene_to

const TRUE_CARD_WIDTH: float = 148.0
const TRUE_CARD_HEIGHT: float = 200.0

const HORIZONTAL_SPACING: float = 10.0 # Espaço horizontal entre colunas
const VERTICAL_SPACING: float = 15.0  # Espaço vertical entre linhas
const START_POSITION: Vector2 = Vector2(249, 140)
const CARDS_PER_ROW: int = 10
const DECK_POSITION: Vector2 = Vector2(-213.0, 540)
const DURATION_PER_CARD: float = 0.4 
const DELAY_BETWEEN_CARDS: float = 0.1

@onready var deck: DeckTutorial = $Deck
@onready var card_manager: Node2D = $CardManager


func _ready() -> void:
	get_parent().connect_change_scene_signals(self)
	deck.deck_ready.connect(distribute_cards)

func distribute_cards():
	if deck.deck_pile.is_empty():
		return
		
	for i in deck.deck_pile.size():
		var card = deck.deck_pile[i]
		card.position = DECK_POSITION

		var row: int = i / CARDS_PER_ROW
		var column: int = i % CARDS_PER_ROW
		
		var target_x: float = START_POSITION.x + column * (TRUE_CARD_WIDTH + HORIZONTAL_SPACING)
		var target_y: float = START_POSITION.y + row * (TRUE_CARD_HEIGHT + VERTICAL_SPACING)
		var target_position: Vector2 = Vector2(target_x, target_y)
		
		var tween = create_tween()
		
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		
		tween.tween_property(card, "position", target_position, DURATION_PER_CARD)
		
		await get_tree().create_timer(DELAY_BETWEEN_CARDS, false).timeout
		
		card.flip(false)
		
			
	print("Distribuição de cartas concluída.")
	
		
func _on_continue_button_button_up() -> void:
	emit_signal("change_scene_to", "TutorialSlot")
	
func _on_return_button_button_up() -> void:
	emit_signal("change_scene_to", "Menu")
