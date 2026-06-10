extends MarginContainer

signal building_selected(scene: PackedScene)
signal catagory_changed(catagory: catagories)
signal close_build_menu()

@export var card_scene: PackedScene

@onready var card_container = $"VBoxContainer/scroll_box/buildings_container"
@onready var catagory_container = $"VBoxContainer/HBoxContainer/catagory_container"
@onready var close_button = $"VBoxContainer/HBoxContainer/exit_button"

@onready var catagory_button = preload("res://scenes/building_system/ui/catagory_button.tscn")

enum catagories {
	All,
	Housing,
	Electricity,
	Nature
}

var placeables := [
	{
		"name": "Small House",
		"scene": "res://scenes/building_system/buildings/small_house.tscn",
		"preview_scale": 2,
		"cost": {
			"stone": 5,
			"wood": 10,
			"iron": 0
		},
		"catagory": catagories.Housing
	},
	{
		"name": "Medium House",
		"scene": "res://scenes/building_system/buildings/medium_house.tscn",
		"preview_scale": 1.5,
		"cost": {
			"stone": 10,
			"wood": 20,
			"iron": 5
		},
		"catagory": catagories.Housing
	}
]

func _ready() -> void:
	create_catagory_buttons()
	
	for placeable in placeables:
		create_card(placeable)
		
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)

func _on_close_button_pressed():
	close_build_menu.emit()

func create_catagory_buttons():
	if catagory_button == null: return
	for catagory in catagories.values():
		var btn = catagory_button.instantiate()
		if catagory_container:
			catagory_container.add_child(btn)
			btn.setup(catagory, catagories.keys()[catagory])
			btn.catagory_changed.connect(on_catagory_selected)

func create_card(placeable):
	var card = card_scene.instantiate()
	if card_container:
		card_container.add_child(card)
		card.setup(
			placeable
		)
		card.category = placeable["catagory"]
		card.building_selected.connect(on_card_selected)

func on_card_selected(building_info: Dictionary):
	building_selected.emit(building_info)

func on_catagory_selected(category):
	if card_container:
		for card in card_container.get_children():
			card.visible = (
				category == catagories.All
				or card.category == category
			)
