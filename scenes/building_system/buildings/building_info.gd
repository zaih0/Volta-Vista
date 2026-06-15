extends Node2D

var info_menu_enabled = false
var stop_first_click = true

var building_data: Dictionary

@onready var building_info_container = $building_info
@onready var building_info_card = $building_info/BuildingInfoCard

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !info_menu_enabled: return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if stop_first_click:
				stop_first_click = false
				return
			building_info_container.visible = true

func setup(info_menu_toggle: bool, building_info: Dictionary):
	info_menu_enabled = info_menu_toggle
	building_data = building_info
	create_building_info()
	print("updated ", info_menu_enabled)
	pass
	
func create_building_info():
	building_info_card.setup(building_data.name, building_data.description)
