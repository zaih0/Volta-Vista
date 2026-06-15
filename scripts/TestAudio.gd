extends Node2D

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D

@export var voice_lines: Array[AudioStream] = []
@export var voice_play_chance: float = 1.0
@export var click_cooldown: float = 0.2

var cooldown_timer: float = 0.0


func _process(delta: float) -> void:
	if cooldown_timer > 0.0:
		cooldown_timer -= delta


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if cooldown_timer > 0.0:
				return

			if mouse_is_inside_character():
				play_random_voice_line()
				cooldown_timer = click_cooldown


func play_random_voice_line() -> void:
	if voice_lines.is_empty():
		print("Geen voicelines ingesteld.")
		return

	if randf() > voice_play_chance:
		print("Geen voiceline deze klik.")
		return

	var chosen_voice: AudioStream = voice_lines.pick_random()

	audio_player.stop()
	audio_player.stream = chosen_voice
	audio_player.play()

	print("Voiceline afgespeeld: ", chosen_voice)


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
