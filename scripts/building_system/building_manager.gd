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
	# Dit opent en sluit het menu met de B-toets
	if event.is_action_pressed("build_mode"):
		toggle_build_mode()

	# Dit roteert het gebouw
	if event.is_action_pressed("rotate_building"):
		if preview_controller:
			preview_controller.rotate_preview()

	# Dit plaatst het gebouw met links, mits je niet op de UI klikt
	if build_mode and event.is_action_pressed("left_click"):
		if !is_mouse_over_building_ui():
			place_building()

	# Dit verwijdert een gebouw met rechts
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
	
	if costs.wood > current_resources.wood: return false
	if costs.stone > current_resources.stone: return false
	if costs.iron > current_resources.iron: return false
	
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

	# IMPORTANT: anchor = mouse cell
	building.global_position = map.to_global(map.map_to_local(cell))
	building.rotation = preview_controller.get_rotation()

	
	#var required_resources
	if check_building_requirements():
		remove_required_resources()
		buildings_parent.add_child(building)
		grid_validator.register_building(cell, building)
		
		building.setup(true)
	
		quest_ui.complete_task("place_building")
