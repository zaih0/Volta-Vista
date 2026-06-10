extends Control

@onready var task_1 = $"NinePatchRect/HBoxContainer/VBoxContainer/MarginContainer3/VBoxContainer/Task1"
@onready var task_2 = $"NinePatchRect/HBoxContainer/VBoxContainer/MarginContainer3/VBoxContainer/Task2"
@onready var task_3 = $"NinePatchRect/HBoxContainer/VBoxContainer/MarginContainer3/VBoxContainer/Task3"
@onready var task_4 = $"NinePatchRect/HBoxContainer/VBoxContainer/MarginContainer3/VBoxContainer/Task4"


var tasks = {
	"move_camera": false,
	"open_build_ui": false,
	"place_building": false,
	"gather_resources": false
}

func _ready():
	update_quest_list()

func _process(delta):
	check_task_inputs()

func check_task_inputs():
	# Task 1: Move camera using W, A, S, D
	if not tasks["move_camera"]:
		if Input.is_action_just_pressed("move_up") \
		or Input.is_action_just_pressed("move_left") \
		or Input.is_action_just_pressed("move_down") \
		or Input.is_action_just_pressed("move_right"):
			complete_task("move_camera")

	# Task 2: Open build UI using B
	if not tasks["open_build_ui"]:
		if Input.is_action_just_pressed("build_mode"):
			complete_task("open_build_ui")

func complete_task(task_name: String):
	if tasks.has(task_name) and not tasks[task_name]:
		tasks[task_name] = true
		update_quest_list()

func update_quest_list():
	task_1.bbcode_enabled = true
	task_2.bbcode_enabled = true
	task_3.bbcode_enabled = true
	task_4.bbcode_enabled = true

	task_1.text = get_task_text("Move camera using W, A, S, D", tasks["move_camera"])
	task_2.text = get_task_text("Open build UI using B", tasks["open_build_ui"])
	task_3.text = get_task_text("Place building using building UI", tasks["place_building"])
	task_4.text = get_task_text("Gather resources", tasks["gather_resources"])

func get_task_text(task_label: String, completed: bool) -> String:
	if completed:
		return "[color=gray][s]" + task_label + "[/s][/color]"
	else:
		return "[color=white]" + task_label + "[/color]"
