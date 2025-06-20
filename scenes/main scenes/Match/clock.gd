extends TextureButton

signal _end_turn
signal _end_game

const MAX_TIME := 60 # Múltiplo de 4
const CLOCK_SPRITE := [preload("res://assets/sprites/Clock/timer_100.png"),
					   preload("res://assets/sprites/Clock/timer_75.png"),
					   preload("res://assets/sprites/Clock/timer_50.png"),
					   preload("res://assets/sprites/Clock/timer_25.png"),
					   preload("res://assets/sprites/Clock/timer_0.png")]

var last_turn: bool = false
@onready var label: Label = $Label
@onready var timer: Timer = $Timer

func _ready() -> void:
	label.text = str(MAX_TIME) #start with correct time

func reset_timer() -> void:
	label.text = str(MAX_TIME)
	self.texture_normal = CLOCK_SPRITE[0]
	timer.start()


func update_label() -> void:
	if int(label.text) > 0:
		label.text = str(int(label.text) - 1)
		timer.start()
	elif not last_turn:
		_end_turn.emit()
	else:
		_end_game.emit()

func update_clock_sprite() -> void:
	var index = CLOCK_SPRITE.find(self.texture_normal)
	self.texture_normal = CLOCK_SPRITE[(index + 1) % 5]

func _on_timer_timeout() -> void:
	update_label()
	if not int(label.text) % (MAX_TIME/4) and not int(label.text) == MAX_TIME:
		update_clock_sprite()


func _on_button_down() -> void:
	if not last_turn:
		_end_turn.emit()
	else:
		_end_game.emit()
