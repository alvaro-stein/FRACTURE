extends Node

@onready var opening: AudioStreamPlayer = $Opening
@onready var card_flip: AudioStreamPlayer = $CardFlip
@onready var card_draw: AudioStreamPlayer = $CardDraw
@onready var score_spin: AudioStreamPlayer = $ScoreSpin
@onready var defeat: AudioStreamPlayer = $Defeat

var master_bus_idx := AudioServer.get_bus_index("Master")
var sfx_bus_idx := AudioServer.get_bus_index("Sfx")
var music_bus_idx := AudioServer.get_bus_index("Music")

func _ready() -> void:
	AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(0.5))
	AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(0.5))
	AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(0.5))
