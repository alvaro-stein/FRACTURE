extends ColorRect

@onready var label: RicherTextLabel = $RicherTextLabel
@onready var button: Button = $Button

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.color.a = 0
	button.modulate.a = 0
	var tween1 = self.create_tween()
	var tween2 = self.create_tween()
	tween1.tween_property(label, "color", Color(1.0, 1.0, 1.0, 1.0), 0.5)
	tween2.tween_property(button, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)


func _on_button_button_up() -> void:
	self.get_parent().emit_signal("change_scene_to", "Menu")
