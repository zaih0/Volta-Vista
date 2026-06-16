extends AudioStreamPlayer

func _ready() -> void:
	volume_db = -12.0
	finished.connect(_on_finished)

	if not playing:
		play()


func _on_finished() -> void:
	play()
