extends Control

@onready var resume_button = $"MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/ResumeButton"
@onready var restart_button = $"MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/RestartButton"
@onready var quit_button = $"MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/QuitButton"

func _ready():
	visible = false

	resume_button.pressed.connect(_on_resume_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	if get_tree().paused:
		get_tree().paused = false
		visible = false
	else:
		get_tree().paused = true
		visible = true

func _on_resume_button_pressed():
	get_tree().paused = false
	visible = false

func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_button_pressed():
	get_tree().quit()
