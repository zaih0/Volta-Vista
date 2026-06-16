extends Node2D

@export var tilemaps: Array[TileMapLayer]

var occupied_tiles := {}


func get_main_tilemap():

	if tilemaps.is_empty():
		push_error("No tilemaps assigned!")
		return null

	return tilemaps[0]


func get_mouse_cell():

	var map = get_main_tilemap()

	if map == null:
		return Vector2i.ZERO

	return map.local_to_map(
		map.to_local(get_global_mouse_position())
	)


func can_place(cell: Vector2i, preview) -> bool:

	if preview == null:
		return false

	for offset in preview.footprint:

		var check = cell + offset

		if occupied_tiles.has(check):
			return false

		if not is_buildable_cell(check):
			return false

	return true


func is_buildable_cell(cell: Vector2i) -> bool:

	var found_any_tile := false

	for map in tilemaps:

		if map == null:
			continue

		var data = map.get_cell_tile_data(cell)

		# if a tile exists here
		if data != null:
			found_any_tile = true

			# blocked tile
			if data.get_custom_data("buildable") != true:
				return false

	# IMPORTANT:
	# no tile at all anywhere = invalid
	if not found_any_tile:
		return false

	return true


func register_building(cell: Vector2i, building):

	for offset in building.footprint:
		occupied_tiles[cell + offset] = building


func delete_building():

	var cell = get_mouse_cell()

	if not occupied_tiles.has(cell):
		return

	var building = occupied_tiles[cell]

	building.queue_free()

	var new_dict := {}

	for key in occupied_tiles.keys():
		if occupied_tiles[key] != building:
			new_dict[key] = occupied_tiles[key]

	occupied_tiles = new_dict
