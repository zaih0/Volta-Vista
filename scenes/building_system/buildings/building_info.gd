extends Node2D

var info_menu_enabled = false
var stop_first_click = true

var building_data: Dictionary = {}

@onready var building_info_card = $building_info/BuildingInfoCard


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !info_menu_enabled:
		return

	if bool(building_data.get("has_ui", true)) == false:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if stop_first_click:
				stop_first_click = false
				return

			building_info_card.visible = true


func setup(info_menu_toggle: bool, building_info: Dictionary):
	info_menu_enabled = info_menu_toggle
	building_data = building_info

	if bool(building_data.get("has_ui", true)) == false:
		return

	create_building_info()

	print("updated ", info_menu_enabled)


func create_building_info():
	var title: String = str(building_data.get("name", "Unknown Building"))
	var description: String = str(building_data.get("description", ""))

	building_info_card.setup(title, description)
