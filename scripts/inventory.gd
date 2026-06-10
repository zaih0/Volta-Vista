extends Node

@export var ui_node: Control
@export var quest_list: MarginContainer

var resources: Dictionary = {
	"iron": 0,
	"stone": 0,
	"wood": 0
}

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
		
		# Mark the gather resources quest as complete
		if quest_list != null:
			if quest_list.has_method("complete_task"):
				quest_list.complete_task("gather_resources")
			else:
				print("FOUT: QuestList mist de functie 'complete_task'!")
		else:
			print("FOUT IN INVENTORY: quest_list is leeg (null) in de Inspector!")
	else:
		print("AFGEKEURD: Het type '" + type + "' wordt niet ondersteund door de inventory!")
