extends Control

var master_bus_idx := AudioServer.get_bus_index("Master")
var sfx_bus_idx := AudioServer.get_bus_index("Sfx")
var music_bus_idx := AudioServer.get_bus_index("Music")
@onready var slider_vol_geral: HSlider = $MarginContainer/VBoxContainer/SliderVolGeral
@onready var slider_vol_sfx: HSlider = $MarginContainer/VBoxContainer/SliderVolSFX
@onready var slider_vol_musica: HSlider = $MarginContainer/VBoxContainer/SliderVolMusica


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Esc"):
		self.get_parent().close_option()


func _on_voltar_button_pressed() -> void:
	self.get_parent().close_option()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slider_vol_geral.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus_idx))
	slider_vol_sfx.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_idx))
	slider_vol_musica.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus_idx))


func _on_slider_vol_geral_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(value))

func _on_slider_vol_sfx_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(value))

func _on_slider_vol_musica_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(value))
