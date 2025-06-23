extends ColorRect

@onready var score: Node = $"../Score"
@onready var Match: GameManager = $".."
const FONT_COLOR_PATH := "theme_override_colors/font_color"
@onready var result: RichTextLabel = $Result
@onready var button: Button = $Button

func _ready() -> void:
	
	var tween = self.create_tween()
	tween.tween_property(self, "color", Color(0, 0, 0, 0.9), 1)
	await get_tree().create_timer(1).timeout
	
	for label in score.get_children():
		label.get_node("Sprite2D").modulate = label.get(FONT_COLOR_PATH)
		if label.get_node("Sprite2D").modulate == Color.BLACK:
			label.get_node("Sprite2D").modulate = Color.WHITE_SMOKE
		elif label.get_node("Sprite2D").modulate == Color.FIREBRICK:
			label.get_node("Sprite2D").modulate = Color(1.0, 0.19, 0.19)
		elif label.get_node("Sprite2D").modulate == Color.SEA_GREEN:
			label.get_node("Sprite2D").modulate = Color(0.123, 0.95, 0.482)
			
		label.get_node("Sprite2D").z_index = 11
		label.get_node("SpinScore").play("spin score")
		await get_tree().create_timer(1).timeout
	var victorious = Match.who_win()
	match victorious:
		"player":
			result.text = "VITÓRIA"
			result.set("theme_override_colors/default_color", Color(0.123, 0.95, 0.482))
		"AI":
			result.text = "DERROTA"
			result.set("theme_override_colors/default_color", Color(1.0, 0.19, 0.19))
		"empate":
			result.text = "EMPATE"
			result.set("theme_override_colors/default_color", Color.WHITE_SMOKE)
	result.visible = true
	
func _on_button_button_down() -> void:
	self.get_parent().emit_signal("change_scene_to", "Menu")
