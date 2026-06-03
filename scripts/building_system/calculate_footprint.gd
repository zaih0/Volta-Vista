extends Node2D

@onready var building: TileMapLayer = $building

var footprint: Array[Vector2i]
var footprint_origin: Vector2i

var shift := Vector2i(-2, -2)

func _ready():

	var cells = building.get_used_cells()
	if cells.is_empty():
		return

	footprint.clear()

	var min_pos = cells[0]

	for cell in cells:
		min_pos.x = min(min_pos.x, cell.x)
		min_pos.y = min(min_pos.y, cell.y)

	footprint_origin = min_pos

	for cell in cells:
		footprint.append((cell - min_pos) + shift)
