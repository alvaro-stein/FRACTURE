extends ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#self.color.a = 0
	pass

func fade_out() -> void:
	#var tween = self.create_tween()
	#tween.tween_property(self, "color", Color(0, 0, 0, 1.0), 0.5)
	#await tween.finished
	$AnimationPlayer.play("transition")

func fade_in() -> void:
	#var tween = self.create_tween()
	#tween.tween_property(self, "color", Color(0, 0, 0, 0), 0.5)
	#await tween.finished
	$AnimationPlayer.play_backwards("transition")
