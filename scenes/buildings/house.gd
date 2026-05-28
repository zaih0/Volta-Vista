extends Node2D

@onready var building: TileMapLayer = $building

var footprint: Array[Vector2i]

func _ready():
	var cells = building.get_used_cells()

	if cells.is_empty():
		return

	# Find top-left used cell
	var min_pos = cells[0]

	for cell in cells:
		min_pos.x = min(min_pos.x, cell.x)
		min_pos.y = min(min_pos.y, cell.y)

	# Convert to local footprint
	for cell in cells:
		footprint.append((cell - min_pos) - Vector2i(1, 2))

	print(footprint)
