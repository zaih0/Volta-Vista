extends Area2D

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var building_sounds: Array[AudioStream] = []
@export var play_chance: float = 1.0
@export var click_cooldown: float = 0.2

var cooldown_timer: float = 0.0


func _ready() -> void:
	input_pickable = true
	print("House audio script ready: ", name)


func _process(delta: float) -> void:
	if cooldown_timer > 0.0:
		cooldown_timer -= delta


func _input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Building clicked")

			if cooldown_timer > 0.0:
				return

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
