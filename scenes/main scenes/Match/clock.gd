extends TextureButton

signal _end_turn
signal _end_game

const MAX_TIME := 60

var last_turn: bool = false
@onready var label: Label = $Label
@onready var timer: Timer = $Timer


func reset_timer() -> void:
	label.text = str(MAX_TIME)
	timer.start()


func update_label() -> void:
	if int(label.text) > 0:
		label.text = str(int(label.text) - 1)
		timer.start()
	elif not last_turn:
		_end_turn.emit()
	else:
		_end_game.emit()


func _on_timer_timeout() -> void:
	update_label()
