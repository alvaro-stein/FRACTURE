extends Node2D
class_name DiscardPile

var discard_pile_hovered: bool = false


func _on_area_2d_mouse_entered() -> void:
	discard_pile_hovered = true


func _on_area_2d_mouse_exited() -> void:
	discard_pile_hovered = false
