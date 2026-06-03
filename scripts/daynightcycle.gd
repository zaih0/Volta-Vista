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

func _process(delta: float) -> void:
	time_of_day += delta / day_length_seconds

	if time_of_day >= 1.0:
		time_of_day -= 1.0

	update_day_night_color()
	check_day_night_change()

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
		# Midnight to sunrise
		var t := time_of_day / 0.25
		target_color = night_color.lerp(dawn_color, t)

	elif time_of_day < 0.5:
		# Sunrise to noon
		var t := (time_of_day - 0.25) / 0.25
		target_color = dawn_color.lerp(day_color, t)

	elif time_of_day < 0.75:
		# Noon to sunset
		var t := (time_of_day - 0.5) / 0.25
		target_color = day_color.lerp(dusk_color, t)

	else:
		# Sunset to midnight
		var t := (time_of_day - 0.75) / 0.25
		target_color = dusk_color.lerp(night_color, t)

	canvas_modulate.color = target_color

func _ready() -> void:
	night_started.connect(_on_night_started)
	day_started.connect(_on_day_started)


func _on_night_started() -> void:
	print("Night has started")


func _on_day_started() -> void:
	print("Day has started")
	
	
