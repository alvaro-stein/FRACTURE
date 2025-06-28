extends Node

var ai_difficulty := "hard"
var race := ""

const CURSOR = {"default": preload("res://assets/sprites/mouse/hand_point.png"),
				"open": preload("res://assets/sprites/mouse/hand_open.png"),
				"closed": preload("res://assets/sprites/mouse/hand_closed.png")}


func set_cursor(str: String) -> void:
	Input.set_custom_mouse_cursor(CURSOR[str], Input.CURSOR_ARROW, Vector2(8, 8))
