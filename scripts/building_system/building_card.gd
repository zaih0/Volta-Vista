extends MarginContainer

signal building_selected(scene: PackedScene)

@onready var title_label = $VBoxContainer/title
@onready var content_container = $VBoxContainer/HBoxContainer/building_preview/preview_container
@onready var building_info_container = $info_container
@onready var building_info_text_container = $info_container/NinePatchRect/HBoxContainer/VBoxContainer/building_info


var building_scene: PackedScene
var category: int

var building_info_visible = false

func setup(building_info: Dictionary):
	title_label.text = building_info.name
	building_scene = load(building_info.scene)
	content_container.add_child(building_scene.instantiate())
	
	var building_info_text = "{building_name}
	
Requires:
	Stone: {building_cost_stone}
	Wood: {building_cost_wood}
	Iron: {building_cost_iron}".format({
		"building_name": building_info.name,
		"building_cost_stone": building_info.cost.stone,
		"building_cost_wood": building_info.cost.wood,
		"building_cost_iron": building_info.cost.iron,
	})
	
	building_info_text_container.text = building_info_text
	building_info_container.visible = false

func _process(delta: float):
	building_info_container.visible = building_info_visible

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("gui card pressed")
			building_selected.emit(building_scene)


func _on_mouse_exited() -> void:
	building_info_visible = false


func _on_mouse_entered() -> void:
	building_info_visible = true
