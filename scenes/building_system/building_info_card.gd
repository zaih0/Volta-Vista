extends Control

@onready var card_title_container = $HBoxContainer/VBoxContainer/content/VBoxContainer/HBoxContainer/title
@onready var card_text_container = $HBoxContainer/VBoxContainer/content/VBoxContainer/text

func setup(title:String, text:String):
	card_title_container.text = title
	card_text_container.text = text
