extends Node2D

@export var tilemaps : Array[TileMapLayer]
@export var buildings_parent : Node2D

@export var house_scene : PackedScene

var current_scene : PackedScene
var preview

var build_mode := false
var rotation_index := 0

# Tracks occupied cells
var occupied_tiles := {}


func _ready():

	if tilemaps.is_empty():
		push_error("No tilemaps assigned in inspector!")

	current_scene = house_scene


func _process(delta):

	if build_mode and preview:
		update_preview_position()


func _input(event):

	# Toggle build mode
	if event.is_action_pressed("build_mode"):
		toggle_build_mode()

	# Select building
	if event.is_action_pressed("select_house"):
		select_building(house_scene)

	# Rotate building
	if event.is_action_pressed("rotate_building"):
		rotate_preview()

	# Place building
	if build_mode and event.is_action_pressed("left_click"):
		place_building()

	# Delete building
	if event.is_action_pressed("right_click"):
		delete_building()


# ---------------------------------------------------
# TILEMAP HELPERS
# ---------------------------------------------------

func get_main_tilemap() -> TileMapLayer:

	if tilemaps.is_empty():
		push_error("No tilemaps assigned!")
		return null

	return tilemaps[0]


func get_mouse_cell() -> Vector2i:

	var map = get_main_tilemap()

	if map == null:
		return Vector2i.ZERO

	return map.local_to_map(
		map.to_local(get_global_mouse_position())
	)


# ---------------------------------------------------
# BUILD MODE
# ---------------------------------------------------

func toggle_build_mode():

	build_mode = !build_mode

	if build_mode:
		create_preview()
	else:
		remove_preview()


func select_building(scene : PackedScene):

	current_scene = scene

	if build_mode:
		remove_preview()
		create_preview()


func create_preview():

	if current_scene == null:
		return

	preview = current_scene.instantiate()

	preview.modulate = Color(1, 1, 1, 0.5)

	add_child(preview)

	update_preview_position()


func remove_preview():

	if preview:
		preview.queue_free()
		preview = null


func update_preview_position():

	var map = get_main_tilemap()

	if map == null:
		return

	var cell = get_mouse_cell()

	var snapped = map.map_to_local(cell)

	preview.global_position = map.to_global(snapped)

	update_preview_color()


func rotate_preview():

	if not preview:
		return

	rotation_index += 1

	if rotation_index > 3:
		rotation_index = 0

	preview.rotation_degrees = rotation_index * 90


# ---------------------------------------------------
# BUILD VALIDATION
# ---------------------------------------------------

func can_place(cell: Vector2i) -> bool:

	if not preview:
		return false

	for offset in preview.footprint:

		var check_cell = cell + offset

		# Occupied by another building
		if occupied_tiles.has(check_cell):
			return false

		# Terrain blocked
		if not is_buildable_cell(check_cell):
			return false

	return true


func is_buildable_cell(cell: Vector2i) -> bool:

	var has_defined_tile := false

	for map in tilemaps:

		if map == null:
			continue

		var data = map.get_cell_tile_data(cell)

		if data == null:
			continue

		has_defined_tile = true

		# Any layer can block placement
		if data.get_custom_data("buildable") == false:
			return false

	return has_defined_tile

# ---------------------------------------------------
# PLACE / DELETE
# ---------------------------------------------------

func place_building():

	var map = get_main_tilemap()

	if map == null:
		return

	var cell = get_mouse_cell()

	if not can_place(cell):
		return

	var building = current_scene.instantiate()

	building.global_position = map.to_global(
		map.map_to_local(cell)
	)

	building.rotation = preview.rotation

	buildings_parent.add_child(building)

	# Mark occupied cells
	for offset in building.footprint:
		occupied_tiles[cell + offset] = building


func delete_building():

	var cell = get_mouse_cell()

	if not occupied_tiles.has(cell):
		return

	var building = occupied_tiles[cell]

	building.queue_free()

	# Rebuild dictionary without deleted building
	var new_dict := {}

	for key in occupied_tiles.keys():

		if occupied_tiles[key] != building:
			new_dict[key] = occupied_tiles[key]

	occupied_tiles = new_dict


# ---------------------------------------------------
# PREVIEW VISUALS
# ---------------------------------------------------

func update_preview_color():

	if not preview:
		return

	var cell = get_mouse_cell()

	if can_place(cell):
		preview.modulate = Color(0, 1, 0, 0.5)
	else:
		preview.modulate = Color(1, 0, 0, 0.5)
