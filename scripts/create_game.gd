extends Control

@onready var city_name_input: TextEdit = $NinePatchRect/nameInput
@onready var start_button: Button = $NinePatchRect/Start

func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)


func _on_start_button_pressed() -> void:
	var entered_name := city_name_input.text.strip_edges()

	if entered_name == "":
		print("Geef je stad eerst een naam.")
		return

	GameData.city_name = entered_name
	print("Stadsnaam opgeslagen: ", GameData.city_name)

	get_tree().change_scene_to_file("res://scenes/game.tscn")
