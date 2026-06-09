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
		"catagory": catagories.Housing
	},
	{
		"name": "Medium House",
		"scene": "res://scenes/building_system/buildings/medium_house.tscn",
		"preview_scale": 1.5,
		"catagory": catagories.Housing
	}
]

func _ready() -> void:
	create_catagory_buttons()
	
	# VEILIGHEIDSCHECK 1: Is de card_scene wel gekoppeld in de Inspector?
	if card_scene == null:
		print("❌ CRITIEKE FOUT: Je bent vergeten de 'card_scene' te koppelen in de Inspector van 'setup_build_ui.gd'!")
		return

	for placeable in placeables:
		# VEILIGHEIDSCHECK 2: Controleer of het bestandspad niet leeg of kapot is
		var path = placeable["scene"]
		if path == "" or path == "res://" or not ResourceLoader.exists(path):
			print("❌ FOUT IN BROWSER: Het gebouw '", placeable["name"], "' heeft een ongeldig of missend bestandspad: ", path)
			continue # Sla dit specifieke gebouw over, maar laat de game NIET crashen!
			
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
			placeable["name"],
			placeable["scene"],
			placeable["preview_scale"]
		)
		card.category = placeable["catagory"]
		card.building_selected.connect(on_card_selected)

func on_card_selected(scene: PackedScene):
	building_selected.emit(scene)

func on_catagory_selected(category):
	if card_container:
		for card in card_container.get_children():
			card.visible = (
				category == catagories.All
				or card.category == category
			)
