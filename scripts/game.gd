extends TileMapLayer

func harvest_tile(cell: Vector2i):
	var tile_data = get_cell_tile_data(cell)

	if tile_data == null:
		return

	var resource_type = tile_data.get_custom_data("resource_type")
	if resource_type == null:
		return

	var amount = tile_data.get_custom_data("resource_amount")

	Inventory.add_resource(resource_type, amount)

	print("Harvested %d %s" % [amount, resource_type])

	erase_cell(cell)
