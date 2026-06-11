extends Node2D

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D



func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if mouse_is_inside_character():
				audio_player.stop()
				audio_player.play()


func mouse_is_inside_character() -> bool:
	if collision_shape.shape == null:
		return false

	if collision_shape.shape is RectangleShape2D:
		var rect_shape := collision_shape.shape as RectangleShape2D
		var mouse_pos := get_global_mouse_position()

		var rect_size := rect_shape.size * collision_shape.global_scale
		var rect_position := collision_shape.global_position - rect_size * 0.5
		var rect := Rect2(rect_position, rect_size)

		return rect.has_point(mouse_pos)

	return false
