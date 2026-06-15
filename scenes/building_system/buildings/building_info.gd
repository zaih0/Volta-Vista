extends Node2D

var info_menu_enabled = false
var stop_first_click = true

func setup(info_menu_toggle: bool):
	info_menu_enabled = info_menu_toggle
	print("updated ", info_menu_enabled)
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !info_menu_enabled: return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if stop_first_click:
				stop_first_click = false
				return
			$building_info.visible = true
