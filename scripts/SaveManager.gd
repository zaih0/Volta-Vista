extends Node

const SAVE_PATH := "user://savegame.json"

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game(save_data: Dictionary) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		push_error("Kon save file niet openen om op te slaan.")
		return

	var json_string := JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()

	print("Game opgeslagen naar: ", SAVE_PATH)


func load_game() -> Dictionary:
	if not has_save_file():
		print("Geen savegame gevonden.")
		return {}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		push_error("Kon save file niet openen om te laden.")
		return {}

	var json_string := file.get_as_text()
	file.close()

	var data = JSON.parse_string(json_string)

	if typeof(data) != TYPE_DICTIONARY:
		push_error("Save file is ongeldig.")
		return {}

	print("Game geladen vanaf: ", SAVE_PATH)
	return data
