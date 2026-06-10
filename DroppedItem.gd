extends Area2D

var resource_type: String = ""
var amount: int = 1
var texture_to_use: Texture2D = null

@onready var sprite: Sprite2D = $Sprite2D  
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var pickup_radius: float = 12.0 
var can_pickup_timer: float = 0.25 

func _ready():
	if texture_to_use != null and sprite != null:
		sprite.texture = texture_to_use

	var tween = create_tween().set_parallel(true)
	var random_direction = Vector2(randf_range(-20, 20), randf_range(-25, -40))
	tween.tween_property(self, "position", position + random_direction, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _process(delta):
	if can_pickup_timer > 0:
		can_pickup_timer -= delta
		return
		
	var global_mouse_pos = get_global_mouse_position()
	var distance = global_position.distance_to(global_mouse_pos)
	
	if distance <= pickup_radius:
		collect_item()

func collect_item():
	var all_nodes = get_tree().get_nodes_in_group("resource_manager")
	var target_node = null
	
	if all_nodes.size() > 0:
		target_node = all_nodes[0]
	else:
		for child in get_parent().get_children():
			if "inventory" in child:
				target_node = child
				break

	if target_node != null and target_node.inventory != null:
		if target_node.inventory.has_method("add_resource"):
			target_node.inventory.add_resource(resource_type, amount)

			var quest_list = get_tree().get_first_node_in_group("quest_list")
			if quest_list != null:
				quest_list.complete_task("gather_resources")
			else:
				print("QuestList niet gevonden in groep quest_list")

			print("Succesvol opgepakt met muis: ", amount, " ", resource_type)
			queue_free()
	else:
		print("Kon inventory niet vinden voor dropped item pickup")
