extends Node2D

signal change_scene_to

@onready var jogar_label: RicherTextLabel = $JogarLabel
@onready var jogar_button: Button = $JogarLabel/JogarButton

@onready var ophidian: Button = $Ophidiano
@onready var ophidian_background: Sprite2D = $OphidianBackground
@onready var ophidian_color_rect: ColorRect = $Ophidiano/ColorRect
@onready var ophidian_description: RichTextLabel = $Ophidiano/Description
@onready var ophidian_name: RicherTextLabel = $Ophidiano/Name

@onready var viridian: Button = $Viridiano
@onready var viridian_background: Sprite2D = $ViridianBackground
@onready var viridian_color_rect: ColorRect = $Viridiano/ColorRect
@onready var viridian_description: RichTextLabel = $Viridiano/Description
@onready var viridian_name: RicherTextLabel = $Viridiano/Name

var character_selected: String = ""
var tween1: Tween
var tween2: Tween
var tween3: Tween
var tween4: Tween

func _input(event):
	if event.is_action_pressed("Esc"):
		_on_voltar_pressed()

func _on_voltar_pressed() -> void:
	AudioGlobal.button.play()
	self.get_parent().close_option()
	self.get_parent().open_option("SingleplayerSelection")


func _ready() -> void:
	get_parent().get_parent().connect_change_scene_signals(self)
	ophidian_background.visible = true
	ophidian_description.visible = true
	ophidian_color_rect.visible = true
	viridian_background.visible = true
	viridian_description.visible = true
	viridian_color_rect.visible = true
	ophidian_background.modulate.a = 0
	ophidian_description.modulate.a = 0
	ophidian_color_rect.modulate.a = 0
	viridian_background.modulate.a = 0
	viridian_description.modulate.a = 0
	viridian_color_rect.modulate.a = 0


# Ophidian logic
func _on_ophidiano_pressed() -> void:
	AudioGlobal.button.play()
	ophidian.release_focus()
	if not character_selected == "Ophidianos":
		ophidian_select()
	else:
		ophidian_deselect()

func ophidian_select():
	jogar_label.bbcode = "[jit2]Jogar com os Ophidianos"
	character_selected = "Ophidianos"
	
	tween2.stop()
	tween3.stop()
	ophidian_description.modulate.a = 0
	ophidian_color_rect.modulate.a = 0
	tween2 = get_tree().create_tween()
	tween3 = get_tree().create_tween()
	tween2.tween_property(ophidian, "position", Vector2(710, ophidian.position.y), 0.5)


func ophidian_deselect():
	character_selected = ""
	jogar_label.bbcode = "[wave]Selecione uma Raça"
	
	tween1 = get_tree().create_tween()
	tween2 = get_tree().create_tween()
	tween3 = get_tree().create_tween()
	tween4 = get_tree().create_tween()
	tween1.tween_property(ophidian_background, "modulate:a", 0, 0.25)
	tween2.tween_property(ophidian, "position", Vector2(250, ophidian.position.y), 0.5)
	tween4.tween_property(viridian, "modulate:a", 1, 0.25)


func _on_ophidiano_mouse_entered() -> void:
	if not character_selected:
		tween1 = get_tree().create_tween()
		tween2 = get_tree().create_tween()
		tween3 = get_tree().create_tween()
		tween4 = get_tree().create_tween()
		tween1.tween_property(ophidian_background, "modulate:a", 1, 0.25)
		tween2.tween_property(ophidian_description, "modulate:a", 1, 0.25)
		tween3.tween_property(ophidian_color_rect, "modulate:a", 1, 0.25)
		tween4.tween_property(viridian, "modulate:a", 0, 0.25)
		viridian.disabled = true



func _on_ophidiano_mouse_exited() -> void:
	if not character_selected:
		tween1 = get_tree().create_tween()
		tween2 = get_tree().create_tween()
		tween3 = get_tree().create_tween()
		tween4 = get_tree().create_tween()
		tween1.tween_property(ophidian_background, "modulate:a", 0, 0.25)
		tween2.tween_property(ophidian_description, "modulate:a", 0, 0.25)
		tween3.tween_property(ophidian_color_rect, "modulate:a", 0, 0.25)
		tween4.tween_property(viridian, "modulate:a", 1, 0.25)
		viridian.disabled = false


# Viridian logic
func _on_viridiano_pressed() -> void:
	AudioGlobal.button.play()
	viridian.release_focus()
	if not character_selected == "Viridianos":
		viridian_select()
	else:
		viridian_deselect()


func viridian_select():
	jogar_label.bbcode = "[jit2]Jogar com os Viridianos"
	character_selected = "Viridianos"
	
	tween2.stop()
	tween3.stop()
	viridian_description.modulate.a = 0
	viridian_color_rect.modulate.a = 0
	tween2 = get_tree().create_tween()
	tween3 = get_tree().create_tween()
	tween2.tween_property(viridian, "position", Vector2(710, viridian.position.y), 0.5)


func viridian_deselect():
	character_selected = ""
	jogar_label.bbcode = "[wave]Selecione uma Raça"
	
	tween1 = get_tree().create_tween()
	tween2 = get_tree().create_tween()
	tween3 = get_tree().create_tween()
	tween4 = get_tree().create_tween()
	tween1.tween_property(viridian_background, "modulate:a", 0, 0.25)
	tween2.tween_property(viridian, "position", Vector2(1170.0, viridian.position.y), 0.5)
	tween4.tween_property(ophidian, "modulate:a", 1, 0.25)


func _on_viridiano_mouse_entered() -> void:
	if not character_selected:
		tween1 = get_tree().create_tween()
		tween2 = get_tree().create_tween()
		tween3 = get_tree().create_tween()
		tween4 = get_tree().create_tween()
		tween1.tween_property(viridian_background, "modulate:a", 1, 0.25)
		tween2.tween_property(viridian_description, "modulate:a", 1, 0.25)
		tween3.tween_property(viridian_color_rect, "modulate:a", 1, 0.25)
		tween4.tween_property(ophidian, "modulate:a", 0, 0.25)
		ophidian.disabled = true


func _on_viridiano_mouse_exited() -> void:
	if not character_selected:
		tween1 = get_tree().create_tween()
		tween2 = get_tree().create_tween()
		tween3 = get_tree().create_tween()
		tween4 = get_tree().create_tween()
		tween1.tween_property(viridian_background, "modulate:a", 0, 0.25)
		tween2.tween_property(viridian_description, "modulate:a", 0, 0.25)
		tween3.tween_property(viridian_color_rect, "modulate:a", 0, 0.25)
		tween4.tween_property(ophidian, "modulate:a", 1, 0.25)
		ophidian.disabled = false


func _on_jogar_pressed() -> void:
	AudioGlobal.button.play()
	jogar_button.release_focus()
	match character_selected:
		"Ophidianos":
			GameSettings.race = "Ophidianos"
			emit_signal("change_scene_to", "Match")
		"Viridianos":
			GameSettings.race = "Viridianos"
			emit_signal("change_scene_to", "Match")
