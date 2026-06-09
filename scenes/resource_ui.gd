extends CanvasLayer

@onready var iron_counter: Label = $IronCounter
@onready var stone_counter: Label = $StoneCounter
@onready var wood_counter: Label = $WoodCounter

func _ready():
	# Stel de posities van de labels netjes onder elkaar in
	setup_label(iron_counter, 20, 50)
	setup_label(stone_counter, 60, 90)
	setup_label(wood_counter, 100, 130)
	
	# Zet de standaard begin-teksten
	if iron_counter: iron_counter.text = "Iron: 0"
	if stone_counter: stone_counter.text = "Stone: 0"
	if wood_counter: wood_counter.text = "Wood: 0"

func setup_label(label: Label, top_offset: int, bottom_offset: int):
	if label == null: return
	label.anchor_left = 1.0
	label.anchor_right = 1.0
	label.anchor_top = 1.0
	label.anchor_bottom = 0.0
	label.offset_left = -180
	label.offset_right = -20
	label.offset_top = top_offset
	label.offset_bottom = bottom_offset
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

# DEZE FUNCTIE VERVANGT DE OUDE 'update_iron_display' EN WERKT VOOR ALLES!
func update_resource_display(type: String, amount: int):
	if type == "iron" and iron_counter:
		iron_counter.text = "Iron: " + str(amount)
	elif type == "stone" and stone_counter:
		stone_counter.text = "Stone: " + str(amount)
	elif type == "wood" and wood_counter:
		wood_counter.text = "Wood: " + str(amount)
