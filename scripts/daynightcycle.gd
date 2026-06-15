extends Node2D

signal day_started
signal night_started

var was_night: bool = false

@onready var canvas_modulate: CanvasModulate = $CanvasModulate

# Length of a full in-game day in real seconds.
@export var day_length_seconds: float = 900.0

# 0.0 = midnight, 0.25 = sunrise, 0.5 = noon, 0.75 = sunset
var time_of_day: float = 0.25

# Adjust these colors to taste.
var dawn_color: Color = Color(0.95, 0.75, 0.55)
var day_color: Color = Color(1.0, 1.0, 1.0)
var dusk_color: Color = Color(0.9, 0.55, 0.45)
var night_color: Color = Color(0.35, 0.42, 0.65)


func _ready() -> void:
	add_to_group("save_provider")
	print("Daynight toegevoegd aan save_provider: ", get_path())
	print("Aantal save providers: ", get_tree().get_nodes_in_group("save_provider").size())

	night_started.connect(_on_night_started)
	day_started.connect(_on_day_started)


func _process(delta: float) -> void:
	time_of_day += delta / day_length_seconds

	if time_of_day >= 1.0:
		time_of_day -= 1.0

	update_day_night_color()
	check_day_night_change()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			print("Key pressed: ", event.keycode)

			if event.keycode == KEY_P:
				print("F5 pressed, saving game...")
				save_current_game()

			if event.keycode == KEY_S:
				print("S pressed, saving game...")
				save_current_game()


func check_day_night_change() -> void:
	var is_night := time_of_day < 0.25 or time_of_day >= 0.75

	if is_night != was_night:
		was_night = is_night

		if is_night:
			night_started.emit()
		else:
			day_started.emit()


func update_day_night_color() -> void:
	var target_color: Color

	if time_of_day < 0.25:
		var t := time_of_day / 0.25
		target_color = night_color.lerp(dawn_color, t)

	elif time_of_day < 0.5:
		var t := (time_of_day - 0.25) / 0.25
		target_color = dawn_color.lerp(day_color, t)

	elif time_of_day < 0.75:
		var t := (time_of_day - 0.5) / 0.25
		target_color = day_color.lerp(dusk_color, t)

	else:
		var t := (time_of_day - 0.75) / 0.25
		target_color = dusk_color.lerp(night_color, t)

	canvas_modulate.color = target_color


func get_save_data() -> Dictionary:
	return {
		"version": 1,
		"city_name": GameData.city_name,
		"time_of_day": time_of_day
	}


func save_current_game() -> void:
	var save_data := get_save_data()
	SaveManager.save_game(save_data)


func apply_save_data(data: Dictionary) -> void:
	GameData.city_name = str(data.get("city_name", ""))

	if data.has("time_of_day"):
		time_of_day = float(data["time_of_day"])

	print("Save toegepast.")
	print("Stadsnaam: ", GameData.city_name)
	print("Time of day: ", time_of_day)


func _on_night_started() -> void:
	print("Night has started")


func _on_day_started() -> void:
	print("Day has started")	
