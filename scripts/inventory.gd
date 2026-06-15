extends Node

signal resource_added(resource_type, amount)

@export var ui_node: Control

var resources: Dictionary = {
	"iron": 999,
	"stone": 999,
	"wood": 999
}

func remove_resource(type: String, quantity: int):
	if !resources.has(type):
		return
	resources[type] -= quantity
	ui_node.update_resource_display(type, resources[type])
	pass

func add_resource(resource_type, amount: int):
	print("--- INVENTORY BINNENGEKOMEN ---")
	
	var type: String = str(resource_type).strip_edges().to_lower()
	
	# Fallback als het oogst-script 'tree' stuurt in plaats van 'wood'
	if type == "tree":
		type = "wood"
	
	if resources.has(type):
		resources[type] += amount
		print("SUCCES: Intern ", type, "-aantal is nu: ", resources[type])
		
		if ui_node != null:
			if ui_node.has_method("update_resource_display"):
				ui_node.update_resource_display(type, resources[type])
			else:
				print("FOUT: De UI node mist de functie 'update_resource_display'!")
		else:
			print("FOUT IN INVENTORY: ui_node is leeg (null) in de Inspector!")
		
		print("SIGNAL EMIT: resource_added -> ", type, ", ", amount)
		resource_added.emit(type, amount)
	else:
		print("AFGEKEURD: Het type '" + type + "' wordt niet ondersteund door de inventory!")
