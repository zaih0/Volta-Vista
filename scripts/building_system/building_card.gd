extends MarginContainer

signal building_selected(scene: PackedScene)

@onready var title_label = $VBoxContainer/title
@onready var content_container = $VBoxContainer/HBoxContainer/building_preview/preview_container

var building_scene: PackedScene
var category: int

func setup(building_name: String, scene_path: String, preview_scale: float):
	title_label.text = building_name
	building_scene = load(scene_path)
	content_container.add_child(building_scene.instantiate())

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("gui card pressed")
			building_selected.emit(building_scene)
