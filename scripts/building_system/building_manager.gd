extends Node2D

@export var buildings_parent: Node2D
@export var building_ui: MarginContainer

@export var preview_controller: Node
@export var grid_validator: Node2D
@export var quest_ui: MarginContainer
@export var inventory: Node

var current_scene: PackedScene
var building_info: Dictionary
var build_mode := false


func _ready():
	if building_ui:
		building_ui.building_selected.connect(select_building)
		building_ui.visible = false
		building_ui.close_build_menu.connect(toggle_build_mode)


func _process(_delta):
	if build_mode and preview_controller:
		preview_controller.update_preview_position()


func _input(event):
	if event.is_action_pressed("build_mode"):
		toggle_build_mode()

	if event.is_action_pressed("rotate_building"):
		if preview_controller:
			preview_controller.rotate_preview()

	if build_mode and event.is_action_pressed("left_click"):
		if !is_mouse_over_building_ui():
			place_building()

	if build_mode and event.is_action_pressed("right_click"):
		if grid_validator:
			grid_validator.delete_building()


func is_mouse_over_building_ui() -> bool:
	var hovered = get_viewport().gui_get_hovered_control()
	return hovered != null and building_ui.is_ancestor_of(hovered)


func toggle_build_mode():
	if building_ui == null:
		return

	build_mode = !build_mode
	building_ui.visible = !building_ui.visible

	if build_mode and current_scene:
		if preview_controller:
			preview_controller.create_preview(current_scene)
	else:
		if preview_controller:
			preview_controller.remove_preview()
		current_scene = null


func select_building(building_dict: Dictionary):
	building_info = building_dict
	current_scene = load(building_info.scene)

	if build_mode:
		preview_controller.create_preview(current_scene)


func check_building_requirements() -> bool:
	var costs = building_info.cost
	var current_resources = inventory.resources

	if costs.wood > current_resources.wood:
		return false
	if costs.stone > current_resources.stone:
		return false
	if costs.iron > current_resources.iron:
		return false

	return true


func remove_required_resources():
	var costs = building_info.cost
	inventory.remove_resource("wood", costs.wood)
	inventory.remove_resource("stone", costs.stone)
	inventory.remove_resource("iron", costs.iron)


func place_building():
	if current_scene == null:
		return

	var cell = grid_validator.get_mouse_cell()

	if not grid_validator.can_place(cell, preview_controller.preview):
		return

	var map = grid_validator.get_main_tilemap()
	var building = current_scene.instantiate()

	building.global_position = map.to_global(map.map_to_local(cell))
	building.rotation = preview_controller.get_rotation()

	if check_building_requirements():
		remove_required_resources()

		var scene_path: String = str(building_info.get("scene", ""))
		var building_id: String = scene_path.get_file().get_basename()

		var saved_building_info := {
			"name": str(building_info.get("name", building_id)),
			"description": str(building_info.get("description", "")),
			"scene": scene_path
		}

		building.set_meta("building_id", building_id)
		building.set_meta("scene_path", scene_path)
		building.set_meta("cell_x", cell.x)
		building.set_meta("cell_y", cell.y)
		building.set_meta("rotation", building.rotation)
		building.set_meta("building_info", saved_building_info)

		buildings_parent.add_child(building)
		grid_validator.register_building(cell, building)

		if building.has_method("setup"):
			building.setup(true, saved_building_info)

		if quest_ui != null and quest_ui.has_method("complete_task"):
			quest_ui.complete_task("place_building")


func get_buildings_save_data() -> Array:
	var buildings_data: Array = []

	if buildings_parent == null:
		print("Geen buildings_parent ingesteld.")
		return buildings_data

	for building in buildings_parent.get_children():
		if not building.has_meta("scene_path"):
			continue

		var building_info_data = building.get_meta("building_info", {})

		buildings_data.append({
			"building_id": str(building.get_meta("building_id", "")),
			"scene_path": str(building.get_meta("scene_path", "")),
			"cell": {
				"x": int(building.get_meta("cell_x", 0)),
				"y": int(building.get_meta("cell_y", 0))
			},
			"rotation": float(building.get_meta("rotation", building.rotation)),
			"building_info": building_info_data
		})

	print("Gebouwen opgeslagen in lijst: ", buildings_data.size())
	return buildings_data


func load_buildings_save_data(buildings_data: Array) -> void:
	if buildings_parent == null:
		print("Geen buildings_parent ingesteld.")
		return

	if grid_validator == null:
		print("Geen grid_validator ingesteld.")
		return

	var map = grid_validator.get_main_tilemap()

	if map == null:
		print("Geen main tilemap gevonden.")
		return

	for child in buildings_parent.get_children():
		child.queue_free()

	for building_data in buildings_data:
		var scene_path: String = str(building_data.get("scene_path", ""))

		if scene_path == "":
			print("Gebouw zonder scene_path overgeslagen.")
			continue

		var building_scene: PackedScene = load(scene_path)

		if building_scene == null:
			print("Kon gebouw scene niet laden: ", scene_path)
			continue

		var building = building_scene.instantiate()

		var cell_data: Dictionary = building_data.get("cell", {})
		var cell := Vector2i(
			int(cell_data.get("x", 0)),
			int(cell_data.get("y", 0))
		)

		building.global_position = map.to_global(map.map_to_local(cell))
		building.rotation = float(building_data.get("rotation", 0.0))

		var saved_building_info: Dictionary = building_data.get("building_info", {})

		building.set_meta("building_id", str(building_data.get("building_id", "")))
		building.set_meta("scene_path", scene_path)
		building.set_meta("cell_x", cell.x)
		building.set_meta("cell_y", cell.y)
		building.set_meta("rotation", building.rotation)
		building.set_meta("building_info", saved_building_info)

		buildings_parent.add_child(building)
		grid_validator.register_building(cell, building)

		if building.has_method("setup"):
			building.setup(true, saved_building_info)

	print("Gebouwen geladen: ", buildings_data.size())
