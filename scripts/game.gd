extends TileMapLayer

@export var build_controller: Node2D
@export var inventory: Node

@onready var iron_clusters: Array[Node2D] = [$IronCluster, $IronCluster2, $IronCluster3]
@onready var stone_clusters: Array[Node2D] = [$StoneClusters] 
@onready var tree_clusters: Array[Node2D] = [$TreeClusters]

var tree_layers: Array[TileMapLayer] = []
var iron_layers: Array[TileMapLayer] = []
var stone_layers: Array[TileMapLayer] = []

var harvest_cooldown: float = 0.0
var is_harvesting: bool = false

# Snelheden per resource (hoe lager het getal, hoe sneller je oogst!)
@export var wood_speed: float = 0.2   
@export var stone_speed: float = 0.6  
@export var iron_speed: float = 1.4   

func _ready():
	for cluster in iron_clusters:
		if cluster == null: continue
		for child in cluster.get_children():
			if child is TileMapLayer: iron_layers.append(child)
				
	for cluster in stone_clusters:
		if cluster == null: continue
		for child in cluster.get_children():
			if child is TileMapLayer: stone_layers.append(child)
				
	for cluster in tree_clusters:
		if cluster == null: continue
		for child in cluster.get_children():
			if child is TileMapLayer: tree_layers.append(child)
	
	print("Gekoppelde ijzer-lagen: ", iron_layers.size())
	print("Gekoppelde steen-lagen: ", stone_layers.size())
	print("Gekoppelde boom-lagen: ", tree_layers.size())

func _process(delta):
	# Loop de timer af voor de oogst-snelheid
	if harvest_cooldown > 0:
		harvest_cooldown -= delta

	# 1. VEILIGHEIDSCHECK: Als de speler in bouwmodus zit, mag hij NOOIT oogsten!
	if build_controller != null and build_controller.build_mode == true:
		return

	# 2. INPUT CHECK: Houdt de speler de linkermuisknop ingedrukt?
	if Input.is_action_pressed("left_click"):
		
		# 3. VERBETERDE UI CHECK: We controleren of het bouwmenu bestaat én ZICHTBAAR is
		if build_controller != null and build_controller.building_ui != null:
			if build_controller.building_ui.visible == true:
				# Alleen als het menu ÉCHT openstaat en je muis eroverheen zweeft, blokkeren we de oogst
				if get_viewport().gui_get_hovered_control() != null:
					return

		# Alleen oogsten als de cooldown volledig voorbij is
		if harvest_cooldown <= 0:
			var resource_speed = harvest_under_mouse()
			if resource_speed > 0.0:
				harvest_cooldown = resource_speed


# Godot roept deze functie PAS aan als je NIET op een UI-knop klikt!
func _unhandled_input(event):
	if event.is_action_pressed("left_click"):
		# Als de bouwmodus aan staat, mag het oogstscript de klik NIET stelen
		if build_controller != null and build_controller.build_mode == true:
			return
			
		# Start het oogstproces
		is_harvesting = true
		if harvest_cooldown <= 0:
			var resource_speed = harvest_under_mouse()
			if resource_speed > 0.0:
				harvest_cooldown = resource_speed

func harvest_under_mouse() -> float:
	var all_resource_layers = []
	all_resource_layers.append_array(iron_layers)
	all_resource_layers.append_array(stone_layers)
	if tree_layers.size() > 0:
		all_resource_layers.append_array(tree_layers)

	for layer in all_resource_layers:
		var cell = layer.local_to_map(layer.get_local_mouse_position())
		var tile_data = layer.get_cell_tile_data(cell)

		if tile_data != null:
			var resource_type: String = ""
			
			var tile_set = layer.tile_set
			if tile_set:
				var layer_exists = false
				for i in range(tile_set.get_custom_data_layers_count()):
					if tile_set.get_custom_data_layer_name(i) == "resource_type":
						layer_exists = true
						break
				
				if layer_exists:
					var raw_data = tile_data.get_custom_data("resource_type")
					if raw_data != null:
						resource_type = str(raw_data).strip_edges().to_lower()
			
			if resource_type == "" or resource_type == "null":
				var layer_name_string = str(layer.name).to_lower()
				if "iron" in layer_name_string:
					resource_type = "iron"
				elif "stone" in layer_name_string:
					resource_type = "stone"
				elif "tree" in layer_name_string or "wood" in layer_name_string:
					resource_type = "wood"
				else:
					continue
			
			if resource_type == "tree":
				resource_type = "wood"
			
			harvest_tile(layer, cell, tile_data, resource_type)
			
			var current_speed: float = 0.5
			if resource_type == "wood":
				current_speed = wood_speed
			elif resource_type == "stone":
				current_speed = stone_speed
			elif resource_type == "iron":
				current_speed = iron_speed
				
			return current_speed
			
	return 0.0

func harvest_tile(layer: TileMapLayer, _cell: Vector2i, tile_data: TileData, resource_type: String):
	var amount = 1
	var tile_set = layer.tile_set
	
	if tile_set:
		var amount_layer_exists = false
		for i in range(tile_set.get_custom_data_layers_count()):
			if tile_set.get_custom_data_layer_name(i) == "resource_amount":
				amount_layer_exists = true
				break
				
		if amount_layer_exists:
			var raw_amount = tile_data.get_custom_data("resource_amount")
			if raw_amount != null and raw_amount > 0:
				amount = int(raw_amount)

	print("Succesvol geoogst: ", amount, " ", resource_type)

	if inventory != null and inventory.has_method("add_resource"):
		inventory.add_resource(resource_type, amount)
