extends Area2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var building_sounds: Array[AudioStream] = []
@export var play_chance: float = 1.0
@export var click_cooldown: float = 0.2

var cooldown_timer: float = 0.0
var click_audio_enabled: bool = true


func _ready() -> void:
	click_audio_enabled = true


func enable_click_audio() -> void:
	await get_tree().create_timer(0.15).timeout
	click_audio_enabled = true
	print("Building click audio enabled")


func _process(delta: float) -> void:
	if cooldown_timer > 0.0:
		cooldown_timer -= delta


func _input(event: InputEvent) -> void:
	if not click_audio_enabled:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if cooldown_timer > 0.0:
				return

			if mouse_is_inside_building():
				play_random_building_sound()
				cooldown_timer = click_cooldown


func play_random_building_sound() -> void:
	if building_sounds.is_empty():
		print("Geen building sounds ingesteld.")
		return

	if randf() > play_chance:
		return

	var chosen_sound: AudioStream = building_sounds.pick_random()

	audio_player.stop()
	audio_player.stream = chosen_sound
	audio_player.play()

	print("Building sound afgespeeld: ", chosen_sound)


func mouse_is_inside_building() -> bool:
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
