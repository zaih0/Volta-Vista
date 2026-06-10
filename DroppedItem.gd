# DroppedItem.gd
extends Area2D

var resource_type: String = ""
var amount: int = 1
var texture_to_use: Texture2D = null

@onready var sprite: Sprite2D = $Sprite2D  
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Instellingen voor het oppakken
var pickup_radius: float = 12.0 

# NIEUW: Cooldown in seconden voordat je het item mag oppakken
var can_pickup_timer: float = 0.25 

func _ready():
	# Toon de juiste sprite
	if texture_to_use != null and sprite != null:
		sprite.texture = texture_to_use

	# Het sprongetje bij het spawnen
	var tween = create_tween().set_parallel(true)
	var random_direction = Vector2(randf_range(-20, 20), randf_range(-25, -40))
	tween.tween_property(self, "position", position + random_direction, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _process(delta):
	# NIEUW: Telt de cooldown timer af naar 0
	if can_pickup_timer > 0:
		can_pickup_timer -= delta
		return # Stop de functie hier, zodat je nog niks kunt oppakken!
		
	# Bereken de afstand tussen dit item en de muis in de wereld
	var global_mouse_pos = get_global_mouse_position()
	var distance = global_position.distance_to(global_mouse_pos)
	
	# Als de cooldown voorbij is én de muis is dichtbij genoeg, pakken we het item op
	if distance <= pickup_radius:
		collect_item()

func collect_item():
	# Zoek in de actieve game naar de node die de inventory heeft
	var all_nodes = get_tree().get_nodes_in_group("resource_manager")
	var target_node = null
	
	if all_nodes.size() > 0:
		target_node = all_nodes[0]
	else:
		# Fallback: Zoek in de kinderen van de parent (je Main/World scene)
		for child in get_parent().get_children():
			if "inventory" in child:
				target_node = child
				break

	# Als we de node met de inventory hebben gevonden, schrijf de resources bij
	if target_node != null and target_node.inventory != null:
		if target_node.inventory.has_method("add_resource"):
			target_node.inventory.add_resource(resource_type, amount)
			print("Succesvol opgepakt met muis: ", amount, " ", resource_type)
			queue_free() # Verwijder het item van de grond
