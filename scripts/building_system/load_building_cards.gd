extends MarginContainer

signal building_selected(scene: PackedScene)

@export var card_scene: PackedScene

@onready var card_container = $"VBoxContainer/scroll_box/buildings_container"

var placeables := [
	{
		"name": "House 1",
		"scene": "res://scenes/building_system/buildings/house.tscn",
		"preview_scale": 2,
		"catagory": "housing"
	},
	{
		"name": "House 2",
		"scene": "res://scenes/building_system/buildings/house2.tscn",
		"preview_scale": 1.5,
		"catagory": "housing"
	}
]

func _ready() -> void:
	for placeable in placeables:	
		create_card(
			placeable.name,
			placeable.scene,
			placeable.preview_scale
		)


func create_card(title: String, scene_path: String, preview_scale: float):

	var card = card_scene.instantiate()

	card_container.add_child(card)

	card.setup(title, scene_path, preview_scale)

	card.building_selected.connect(_on_card_selected)


func _on_card_selected(scene: PackedScene):

	building_selected.emit(scene)
