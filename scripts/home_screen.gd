extends Control

@onready var load_game_button: Button = $"buttons/Load Game"

func _ready() -> void:
	get_tree().paused = false

	# Load Game knop alleen aanzetten als er een save bestaat
	if SaveManager.has_save_file():
		load_game_button.disabled = false
	else:
		load_game_button.disabled = true


func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/create_game.tscn")


func _on_load_game_pressed() -> void:
	var save_data := SaveManager.load_game()

	if save_data.is_empty():
		print("Geen geldige savegame gevonden.")
		return

	GameData.is_loading_save = true
	GameData.loaded_save_data = save_data
	GameData.city_name = str(save_data.get("city_name", ""))

	print("Savegame wordt geladen...")
	print("Stadsnaam uit save: ", GameData.city_name)

	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
