extends MarginContainer

signal building_selected(scene: PackedScene)
signal catagory_changed(catagory: catagories)


@export var card_scene: PackedScene

@onready var card_container = $"VBoxContainer/scroll_box/buildings_container"
@onready var catagory_container = $"VBoxContainer/HBoxContainer/catagory_container"

@onready var catagory_button = preload("res://scenes/building_system/ui/catagory_button.tscn")

enum catagories {
	All,
	Housing,
	Electricity,
	Nature
}

var placeables := [
	{
		"name": "House 1",
		"scene": "res://scenes/building_system/buildings/house.tscn",
		"preview_scale": 2,
		"catagory": catagories.Housing
	},
	{
		"name": "House 2",
		"scene": "res://scenes/building_system/buildings/house2.tscn",
		"preview_scale": 1.5,
		"catagory": catagories.Housing
	}
]

func _ready() -> void:
	create_catagory_buttons()
	for placeable in placeables:
		create_card(
			placeable
		)

func create_catagory_buttons():
	for catagory in catagories.values():
		var btn = catagory_button.instantiate()
		catagory_container.add_child(btn)

		btn.setup(catagory, catagories.keys()[catagory])
		btn.catagory_changed.connect(on_catagory_selected)

func create_card(placeable):
	var card = card_scene.instantiate()

	card_container.add_child(card)
	card.setup(
		placeable["name"],
		placeable["scene"],
		placeable["preview_scale"]
	)

	card.category = placeable["catagory"]
	card.building_selected.connect(on_card_selected)

func on_card_selected(scene: PackedScene):
	building_selected.emit(scene)

func on_catagory_selected(category):
	for card in card_container.get_children():
		card.visible = (
			category == catagories.All
			or card.category == category
		)
