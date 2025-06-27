# Em PointingArrow.gd
extends Node2D

var _tween: Tween

func point_at(target_position: Vector2, offset: Vector2 = Vector2(0, -120)) -> void:
	self.global_position = target_position + offset
	self.look_at(target_position)
	
	_start_pulsing_animation()

func _start_pulsing_animation() -> void:
	if _tween:
		_tween.kill()

	var move_vector = Vector2.RIGHT.rotated(self.rotation) * 10 
	_tween = create_tween().set_loops()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(self, "position", self.position + move_vector, 0.7)
	_tween.tween_property(self, "position", self.position, 0.7)

func show_arrow() -> void:
	self.show()

func hide_arrow() -> void:
	self.hide()
