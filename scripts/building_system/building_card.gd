extends MarginContainer

signal building_selected(scene: PackedScene)

@onready var title_label = $VBoxContainer/title
@onready var content_container = $VBoxContainer/HBoxContainer/building_preview/preview_container

var building_scene: PackedScene
var category: int

func setup(building_name: String, scene_path: String, preview_scale: float):
	# Pas deze namen aan naar de Nodes die op JOUW kaart zitten (zoals een Label)
	if has_node("Label"):
		$Label.text = building_name
	
	# 1. VEILIGHEIDSCHECK: Is het pad leeg of ongeldig?
	if scene_path == "" or scene_path == "res://":
		print("❌ FOUT OP KAART: Het scene-pad is leeg voor: ", building_name)
		return
		
	# 2. VEILIGHEIDSCHECK: Bestaat het bestand wel echt op de computer?
	if not ResourceLoader.exists(scene_path):
		print("❌ FOUT OP KAART: Het bestand bestaat niet: ", scene_path)
		return

	# Pas als alles veilig is, laden we de scène in
	var verified_scene = load(scene_path)
	if verified_scene:
		# Zorg dat 'current_scene' of 'building_scene' exact de naam is 
		# van de variabele die jouw kaart gebruikt om de scène in op te slaan!
		if "building_scene" in self:
			self.building_scene = verified_scene
		elif "current_scene" in self:
			self.current_scene = verified_scene

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("gui card pressed")
			building_selected.emit(building_scene)
