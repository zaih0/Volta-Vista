extends TileMapLayer

@export var dropped_item_scene: PackedScene 
@export var wood_texture: Texture2D
@export var stone_texture: Texture2D
@export var iron_texture: Texture2D
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
			
			# VERANDERD: tile_set is hernoemd naar current_tileset
			var current_tileset = layer.tile_set
			if current_tileset:
				var layer_exists = false
				for i in range(current_tileset.get_custom_data_layers_count()):
					if current_tileset.get_custom_data_layer_name(i) == "resource_type":
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

func harvest_tile(layer: TileMapLayer, cell: Vector2i, tile_data: TileData, resource_type: String):
	var amount = 1
	# VERANDERD: tile_set is hernoemd naar current_tileset
	var current_tileset = layer.tile_set
	
	if current_tileset:
		var amount_layer_exists = false
		for i in range(current_tileset.get_custom_data_layers_count()):
			if current_tileset.get_custom_data_layer_name(i) == "resource_amount":
				amount_layer_exists = true
				break
				
		if amount_layer_exists:
			var raw_amount = tile_data.get_custom_data("resource_amount")
			if raw_amount != null and raw_amount > 0:
				amount = int(raw_amount)

	print("Succesvol geoogst: ", amount, " ", resource_type)

	# Items fysiek spawnen op de map
	spawn_dropped_item(layer, cell, resource_type, amount)



func spawn_dropped_item(layer: TileMapLayer, cell: Vector2i, type: String, amt: int):
	if dropped_item_scene == null:
		push_error("Vergeet niet om dropped_item_scene toe te wijzen in de Inspector!")
		return
		
	# 1. Kies de juiste AtlasTexture op basis van het type resource
	var chosen_texture: Texture2D = null
	if type == "wood":
		chosen_texture = wood_texture
	elif type == "stone":
		chosen_texture = stone_texture
	elif type == "iron":
		chosen_texture = iron_texture
		
	# 2. Bereken de exacte positie van het midden van de tegel
	var map_position = layer.map_to_local(cell)
	var global_tile_position = layer.to_global(map_position)
	
	# 3. Instantieer de item scene
	var item_instance = dropped_item_scene.instantiate()
	
	# 4. Geef de variabelen EN de gekozen texture mee
	item_instance.position = global_tile_position
	item_instance.resource_type = type
	item_instance.amount = amt
	item_instance.z_index = 5 # Netjes boven de grond-tegels getekend
	
	if "texture_to_use" in item_instance:
		item_instance.texture_to_use = chosen_texture
	
	# 5. Voeg toe aan de wereld
	get_parent().add_child(item_instance)
