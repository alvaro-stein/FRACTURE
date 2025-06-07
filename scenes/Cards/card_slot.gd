extends Node2D

signal hovered
signal hovered_off

var is_empty: bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# All Cards slots must be a child of CardManager or this will error
	get_parent().connect_card_slot_signals(self)


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
