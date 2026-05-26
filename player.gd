extends Area2D
@export var speed = 400
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
		
		# Set animation based on direction
		match current_direction:
			"up":
				$AnimatedSprite2D.animation = "walk_up"
			"down":
				$AnimatedSprite2D.animation = "walk_down"
			"left":
				$AnimatedSprite2D.animation = "walk_left"
			"right":
				$AnimatedSprite2D.animation = "walk_right"
		
		$AnimatedSprite2D.flip_h = false  # Reset flip_h since we have separate animations
		$AnimatedSprite2D.flip_v = false  # Reset flip_v since we have separate animations
		$AnimatedSprite2D.play()
	else:
		# When stopped, play idle animation based on last direction
		match last_direction:
			"up":
				$AnimatedSprite2D.animation = "walk_up"
			"down":
				$AnimatedSprite2D.animation = "walk_down"
			"left":
				$AnimatedSprite2D.animation = "walk_left"
			"right":
				$AnimatedSprite2D.animation = "walk_right"
		$AnimatedSprite2D.stop()  # Stop animation to show idle frame
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
