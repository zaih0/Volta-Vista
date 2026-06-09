extends CanvasLayer

@onready var iron_counter: Label = $IronCounter

func _ready():
	# 1. Zet het anker (anchor) van het label helemaal naar de rechterbovenhoek
	iron_counter.anchor_left = 1.0
	iron_counter.anchor_right = 1.0
	iron_counter.anchor_top = 0.0
	iron_counter.anchor_bottom = 0.0
	
	# 2. Schuif de tekst een klein stukje (offset) weg van de randen
	# -150 pixels vanaf de rechterkant, 20 pixels vanaf de bovenkant
	iron_counter.offset_left = -180
	iron_counter.offset_right = -20
	iron_counter.offset_top = 20
	iron_counter.offset_bottom = 50
	
	# 3. Zorg dat de tekst IN het vakje ook netjes rechts uitlijnt
	iron_counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	# Standaard begin-tekst
	iron_counter.text = "Iron: 0"

# Deze functie blijft hetzelfde en wordt aangeroepen door je inventory
func update_iron_display(amount: int):
	iron_counter.text = "Iron: " + str(amount)
