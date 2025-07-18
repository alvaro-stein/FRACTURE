extends ColorRect

@onready var score: Node = $"../Score"
@onready var Match: GameManager = $".."
const FONT_COLOR_PATH := "theme_override_colors/font_color"
@onready var result: RichTextLabel = $Result
@onready var sair: Button = $Sair
@onready var reiniciar: Button = $Reiniciar
@onready var sum_points: Label = $SumPoints

func _ready() -> void:
	$"../PauseButton".queue_free()
	var total_points = 0
	var tween = self.create_tween()
	tween.tween_property(self, "color", Color(0, 0, 0, 0.9), 1)
	await get_tree().create_timer(1, false).timeout
	
	for label in score.get_children():
		
		total_points += int(label.text)
		label.get_node("Sprite2D").modulate = label.get(FONT_COLOR_PATH)
		if label.get_node("Sprite2D").modulate == Color.BLACK:
			AudioGlobal.even_score.play()
			label.get_node("Sprite2D").modulate = Color.WHITE_SMOKE
		elif label.get_node("Sprite2D").modulate == Color.FIREBRICK:
			AudioGlobal.lose_score.play()
			label.get_node("Sprite2D").modulate = Color(1.0, 0.19, 0.19)
		elif label.get_node("Sprite2D").modulate == Color.SEA_GREEN:
			AudioGlobal.win_score.play()
			label.get_node("Sprite2D").modulate = Color(0.123, 0.95, 0.482)
		
		label.get_node("Sprite2D").z_index = 11
		label.get_node("SpinScore").play("spin score")
		
		await get_tree().create_timer(0.75, false).timeout
	
	var victorious = Match.who_win()
	match victorious:
		"player":
			result.text = "[wave amp=15 freq=3]VITÓRIA"
			result.set("theme_override_colors/default_color", Color(0.123, 0.95, 0.482))
		"AI":
			result.text = "[wave amp=15 freq=3]DERROTA"
			result.set("theme_override_colors/default_color", Color(1.0, 0.19, 0.19))
		"empate":
			result.text = "[wave amp=15 freq=3]EMPATE"
			result.set("theme_override_colors/default_color", Color.WHITE_SMOKE)
	
	sum_points.text = sum_points.text + str(total_points)
	if total_points > 0:
		sum_points.set(FONT_COLOR_PATH, Color(0.123, 0.95, 0.482))
	elif total_points < 0:
		sum_points.set(FONT_COLOR_PATH, Color(1.0, 0.19, 0.19))
	else:
		sum_points.set(FONT_COLOR_PATH, Color.WHITE_SMOKE)
		
	sum_points.visible = true
	await get_tree().create_timer(0.75, false).timeout
	result.visible = true
	if victorious == "player":
		AudioGlobal.win.play()
	elif victorious == "AI":
		AudioGlobal.defeat.play()
	else:
		pass
	await get_tree().create_timer(0.75, false).timeout
	sair.visible = true
	reiniciar.visible = true
	

func _on_sair_pressed() -> void:
	AudioGlobal.button.play()
	self.get_parent().emit_signal("change_scene_to", "Menu")


func _on_reiniciar_pressed() -> void:
	AudioGlobal.button.play()
	self.get_parent().emit_signal("change_scene_to", "Match")
