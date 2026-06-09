extends Node

@export var ui_node: CanvasLayer

var iron_count: int = 0

func add_resource(resource_type, amount: int):
	print("--- INVENTORY BINNENGEKOMEN ---")
	print("Ontvangen type: ", resource_type, " (Type is: ", typeof(resource_type), ")")
	print("Ontvangen aantal: ", amount)
	
	# HIER GEFIXT: 'lower()' vervangen door 'to_lower()'
	if str(resource_type).strip_edges().to_lower() == "iron":
		iron_count += amount
		print("SUCCES: Intern ijzer-aantal is nu: ", iron_count)
		
		if ui_node != null:
			print("UI Node is gevonden! Functie aanroepen...")
			ui_node.update_iron_display(iron_count)
		else:
			print("FOUT IN INVENTORY: ui_node is leeg (null) in de Inspector!")
	else:
		print("AFGEKEURD: Het type '" + str(resource_type) + "' is ongelijk aan 'iron'!")
