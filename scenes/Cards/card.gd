extends Node2D

signal hovered
signal hovered_off

@export var front: Sprite2D
@export var back: Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# All Cards must be a child of CardManager or this will error
	get_parent().connect_card_signals(self)


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
