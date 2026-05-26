extends Camera2D
@export var speed = 500
@export var zoom_speed = 0.1  # How fast the zoom changes
@export var min_zoom = 0.5    # Maximum zoom out (smaller number = more zoomed out)
@export var max_zoom = 2.0    # Maximum zoom in (larger number = more zoomed in)
var screen_size
var last_direction = "down"  # Track last direction for when stopped

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	var current_direction = last_direction
	
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
		current_direction = "right"
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
		current_direction = "left"
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
		current_direction = "down"
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
		current_direction = "up"

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		last_direction = current_direction
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	# Zoom in/out controls
	if Input.is_action_just_pressed("zoom_in"):
		zoom_in()
	if Input.is_action_just_pressed("zoom_out"):
		zoom_out()
	
	# Alternative: Smooth zoom with mouse wheel (if you prefer)
	# var wheel_input = Input.get_axis("zoom_out", "zoom_in")  # You'd need to set these up in Input Map
	# if wheel_input != 0:
	#     zoom_with_wheel(wheel_input, delta)

func zoom_in():
	# Zoom in (decrease zoom.x and zoom.y)
	var new_zoom = zoom.x - zoom_speed
	if new_zoom >= min_zoom and new_zoom <= max_zoom:
		zoom = Vector2(new_zoom, new_zoom)

func zoom_out():
	# Zoom out (increase zoom.x and zoom.y)
	var new_zoom = zoom.x + zoom_speed
	if new_zoom >= min_zoom and new_zoom <= max_zoom:
		zoom = Vector2(new_zoom, new_zoom)

func zoom_with_wheel(direction, delta):
	# For smooth mouse wheel zooming
	var new_zoom = zoom.x - (direction * zoom_speed * 10 * delta)
	new_zoom = clamp(new_zoom, min_zoom, max_zoom)
	zoom = Vector2(new_zoom, new_zoom)
