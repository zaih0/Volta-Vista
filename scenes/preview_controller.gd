extends Node

var preview
var rotation_index := 0


func create_preview(scene: PackedScene):

	remove_preview()

	if scene == null:
		return

	preview = scene.instantiate()
	preview.modulate = Color(1, 1, 1, 0.5)

	get_parent().add_child(preview)


func remove_preview():

	if preview:
		preview.queue_free()
		preview = null


func update_preview_position():

	if preview == null:
		return

	var validator = get_node("../grid_validator")
	var map = validator.get_main_tilemap()

	var cell = validator.get_mouse_cell()

	# FIXED SNAP (no double conversion)
	preview.global_position = map.to_global(map.map_to_local(cell))

	update_color(validator, cell)


func update_color(validator, cell):

	if validator.can_place(cell, preview):
		preview.modulate = Color(0, 1, 0, 0.5)
	else:
		preview.modulate = Color(1, 0, 0, 0.5)


func rotate_preview():

	if preview == null:
		return

	rotation_index = (rotation_index + 1) % 4
	preview.rotation_degrees = rotation_index * 90


func get_rotation():
	return rotation_index * 90
