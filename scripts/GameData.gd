extends Node

var city_name: String = ""

var is_loading_save: bool = false
var loaded_save_data: Dictionary = {}

var placed_buildings: Array[Dictionary] = []


func register_building(building_id: String, scene_path: String, position: Vector2) -> void:
	placed_buildings.append({
		"building_id": building_id,
		"scene_path": scene_path,
		"position": {
			"x": position.x,
			"y": position.y
		}
	})

	print("Gebouw geregistreerd: ", building_id, " op ", position)


func clear_buildings() -> void:
	placed_buildings.clear()
