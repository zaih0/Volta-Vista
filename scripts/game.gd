extends TileMapLayer # Of 'extends Node2D', afhankelijk van het type van je 'map' node

@export var inventory: Node  

# We zoeken specifiek naar de IronCluster nodes die onder 'map' hangt
@onready var iron_clusters: Array[Node2D] = [$IronCluster, $IronCluster2, $IronCluster3]

var iron_layers: Array[TileMapLayer] = []

func _ready():
	# Loop door ELK individueel cluster in je lijst heen
	for cluster in iron_clusters:
		# Veiligheidscontrole: skip als een cluster (nog) niet bestaat of leeg is
		if cluster == null:
			continue
			
		# Vraag NU get_children() op van het losse cluster object
		for child in cluster.get_children():
			if child is TileMapLayer:
				iron_layers.append(child)
	
	print("Automatisch gekoppelde ijzer-lagen onder álle IronClusters: ", iron_layers.size())

func _input(event):
	if event.is_action_pressed("left_click"):
		harvest_under_mouse()

func harvest_under_mouse():
	# Loop door alle automatisch gevonden ijzer-lagen
	for layer in iron_layers:
		# Bereken de cel op basis van de muispositie van DEZE specifieke laag
		var cell = layer.local_to_map(layer.get_local_mouse_position())
		var tile_data = layer.get_cell_tile_data(cell)

		# Hebben we ijzer gevonden op deze laag?
		if tile_data != null:
			print("IJZER gevonden op laag: ", layer.name, " op cel: ", cell)
			harvest_tile(layer, cell, tile_data)
			return # Stop direct met zoeken, we hebben er al één geoogst!

	print("Geen ijzer gevonden op deze positie op de ijzer-lagen.")

func harvest_tile(layer: TileMapLayer, cell: Vector2i, tile_data: TileData):
	var resource_type = tile_data.get_custom_data("resource_type")
	var amount = tile_data.get_custom_data("resource_amount")

	if resource_type == null or resource_type == "":
		print("Tegel op ", layer.name, " mist 'resource_type' in Custom Data.")
		return 

	# Dit is de meest stabiele manier om tekst en variabelen te combineren in Godot 4
	print("Succesvol geoogst uit {layer}: {amount} {type}".format({
		"layer": layer.name,
		"amount": amount,
		"type": resource_type
	}))

	# Inventory check
	if inventory != null and inventory.has_method("add_resource"):
		inventory.add_resource(resource_type, amount)

	# Wis de ijzer-tegel op de laag waar we hem daadwerkelijk hebben gevonden
